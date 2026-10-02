# frozen_string_literal: true

require 'csv'

module Morphosource
  ##
  # Read-only snapshot of the reviewer state this effort rewrites: the stored values, what
  # reviewer resolution returns for them today, and the inputs that resolution reads. The
  # verification baseline for the backfills, and the work list ticket 10's strip is scoped by --
  # once the property is undeclared nothing can enumerate which records held values, so a record
  # missing from this file keeps its triples permanently.
  #
  # @example
  #   Morphosource::DownloadReviewerExport.new(path: '/data/reviewers.csv').call
  class DownloadReviewerExport
    COLUMNS = %w[
      id
      model
      media_id
      stored_download_reviewer
      resolved_reviewers
      owner
      manager_count
      manager_ms_ids
      fileset_accessibility
      request_status
    ].freeze

    VALUE_SEPARATOR = '|'

    SCOPES = %w[all organizations media cart_items].freeze

    BATCH_SIZE = 1000

    UNRESOLVABLE = :unresolvable

    attr_reader :path, :scope, :logger, :summary

    # @param path [String] where to write the CSV; must survive a deploy
    # @param scope [String] one of SCOPES
    # @param logger [Logger]
    def initialize(path:, scope: 'all', logger: Rails.logger)
      raise ArgumentError, 'path is required' if path.blank?
      raise ArgumentError, "scope must be one of #{SCOPES.join(', ')}; got #{scope.inspect}" unless SCOPES.include?(scope.to_s)

      @path = path.to_s
      @scope = scope.to_s
      @logger = logger
      @summary = new_summary
    end

    # @return [Hash] the summary counts, also logged
    def call
      @summary = new_summary
      @processed = 0
      @reviewer_cache = {}
      logger.info("[morphosource:download_reviewer:export] writing #{scope} export to #{path}")

      write_export
      log_summary
      summary
    end

    # @return [Array<String>]
    def summary_lines
      lines = ["export written to #{path} (scope: #{scope})"]
      lines.concat(organization_summary_lines)
      lines.concat(media_summary_lines)
      lines.concat(cart_item_summary_lines)
      lines << "in Solr but not in Fedora: #{summary[:unloadable].count}" if summary[:unloadable].any?
      lines << "Media whose resolution hit a dangling record: #{summary[:unresolvable].count}" if summary[:unresolvable].any?
      lines
    end

    private

    def write_export
      temporary_path = "#{path}.#{Process.pid}.part"

      CSV.open(temporary_path, 'w') do |csv|
        csv << COLUMNS
        if organizations?
          export_organization_collections(csv)
          export_deprecated_organizations(csv)
        end
        export_media(csv) if media?
        export_cart_items(csv) if cart_items?
      end

      File.rename(temporary_path, path)
    ensure
      FileUtils.rm_f(temporary_path)
    end

    def organizations?
      scope == 'all' || scope == 'organizations'
    end

    def media?
      scope == 'all' || scope == 'media'
    end

    def cart_items?
      scope == 'all' || scope == 'cart_items'
    end

    def export_organization_collections(csv)
      each_record(OrganizationCollection, 'has_model_ssim:OrganizationCollection') do |organization|
        summary[:organizations] += 1
        manager_ms_ids = organization.managers.map(&:ms_id)
        stored = present_values(organization.download_reviewer)
        summary[:organizations_with_stored_reviewer] += 1 if stored.any?

        if manager_ms_ids.empty?
          summary[:zero_manager_organizations] << { id: organization.id, title: Array(organization.title).first }
        end

        csv << row(
          id: organization.id,
          model: 'OrganizationCollection',
          stored_download_reviewer: join(stored),
          resolved_reviewers: join(organization.media_download_reviewers),
          manager_count: manager_ms_ids.count,
          manager_ms_ids: join(manager_ms_ids)
        )
      end
    end

    def export_deprecated_organizations(csv)
      each_record(Organization, 'has_model_ssim:Organization') do |organization|
        summary[:deprecated_organizations] += 1
        stored = present_values(organization.download_reviewer)
        summary[:deprecated_organizations_with_stored_reviewer] += 1 if stored.any?

        csv << row(
          id: organization.id,
          model: 'Organization',
          stored_download_reviewer: join(stored)
        )
      end
    end

    def export_media(csv)
      each_solr_document('has_model_ssim:Media') do |media|
        summary[:media] += 1
        stored = present_values(media.download_reviewer)
        summary[:media_with_stored_reviewer] += 1 if stored.any?

        csv << row(
          id: media.id,
          model: 'Media',
          stored_download_reviewer: join(stored),
          resolved_reviewers: join(resolve_reviewers(media)),
          owner: join(media.user_with_ownership),
          fileset_accessibility: join(media.fileset_accessibility)
        )
      end
    end

    # Pending rows only -- see #pending_cart_items. The total is still counted so a reader can
    # see how much of the table this file deliberately omits.
    def export_cart_items(csv)
      summary[:cart_items_total] = CartItem.count

      pending_cart_items.find_each(batch_size: BATCH_SIZE) do |cart_item|
        summary[:cart_items] += 1
        stored = present_values(cart_item.reviewers)
        summary[:cart_items_with_reviewers] += 1 if stored.any?

        csv << row(
          id: cart_item.id,
          model: 'CartItem',
          media_id: cart_item.work_id,
          stored_download_reviewer: join(stored),
          request_status: cart_item.request_status
        )
        log_progress
      end
    end

    def pending_cart_items
      CartItem
        .where.not(date_requested: nil)
        .where(date_canceled: nil, date_denied: nil, date_cleared: nil, date_approved: nil)
        .where('date_expired IS NULL OR date_expired >= ?', Date.current)
    end

    def resolve_reviewers(media)
      key = [media.download_reviewer, media.user_with_ownership]
      resolved = @reviewer_cache.fetch(key) { @reviewer_cache[key] = resolve_uncached(media) }
      return resolved unless resolved == UNRESOLVABLE

      summary[:unresolvable] << media.id
      []
    end

    def resolve_uncached(media)
      media.reviewer
    rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone => e
      logger.warn("[morphosource:download_reviewer:export] Media #{media.id} resolves through a " \
                  "record that is in Solr but not in Fedora (#{e.class}); resolution left blank")
      UNRESOLVABLE
    end

    def each_record(model, query)
      each_solr_id(query) do |id|
        begin
          yield model.find(id)
        rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
          summary[:unloadable] << id
          logger.warn("[morphosource:download_reviewer:export] #{model} #{id} is in Solr but not in " \
                      "Fedora; skipped")
        end
        log_progress
      end
    end

    def each_solr_id(query)
      each_solr_batch(query, 'id') do |docs|
        docs.each { |doc| yield doc['id'] }
      end
    end

    def each_solr_document(query)
      each_solr_batch(query, '*') do |docs|
        docs.each do |doc|
          yield SolrDocument.new(doc)
          log_progress
        end
      end
    end

    def each_solr_batch(query, fields)
      cursor = '*'

      loop do
        result = Morphosource::SolrService.new.get(
          query, fl: fields, rows: BATCH_SIZE, sort: 'id asc', cursorMark: cursor
        )
        yield result['response']['docs']

        next_cursor = result['nextCursorMark']
        break if next_cursor.blank? || next_cursor == cursor

        cursor = next_cursor
      end
    end

    def row(values)
      COLUMNS.map { |column| values[column.to_sym] }
    end

    def present_values(values)
      Array(values).reject(&:blank?)
    end

    def join(values)
      present_values(values).join(VALUE_SEPARATOR)
    end

    def log_progress
      @processed = @processed.to_i + 1
      return unless (@processed % BATCH_SIZE).zero?

      logger.info("[morphosource:download_reviewer:export] #{@processed} records exported")
    end

    def organization_summary_lines
      return ['OrganizationCollections: not measured in this run'] unless organizations?

      lines = ["OrganizationCollections: #{summary[:organizations]} " \
               "(#{summary[:organizations_with_stored_reviewer]} with a stored download_reviewer)"]
      lines << "organizations with zero Managers: #{summary[:zero_manager_organizations].count}"
      summary[:zero_manager_organizations].each do |organization|
        lines << "  zero Managers: #{organization[:id]} #{organization[:title]}"
      end
      lines << "deprecated Organizations: #{summary[:deprecated_organizations]} " \
               "(#{summary[:deprecated_organizations_with_stored_reviewer]} with a stored download_reviewer)"
      lines
    end

    def media_summary_lines
      return ['Media: not measured in this run'] unless media?

      ["Media: #{summary[:media]} (#{summary[:media_with_stored_reviewer]} with a stored download_reviewer)"]
    end

    def cart_item_summary_lines
      return ['CartItems: not measured in this run'] unless cart_items?

      ["CartItems: #{summary[:cart_items]} pending of #{summary[:cart_items_total]} total " \
       "(#{summary[:cart_items_with_reviewers]} with stored reviewers); " \
       'rows in any other status are deliberately not in this file']
    end

    def new_summary
      {
        scope: scope,
        path: path,
        organizations: 0,
        organizations_with_stored_reviewer: 0,
        zero_manager_organizations: [],
        deprecated_organizations: 0,
        deprecated_organizations_with_stored_reviewer: 0,
        media: 0,
        media_with_stored_reviewer: 0,
        cart_items: 0,
        cart_items_with_reviewers: 0,
        cart_items_total: 0,
        unloadable: [],
        unresolvable: []
      }
    end

    def log_summary
      summary_lines.each { |line| log(line) }

      if summary[:unloadable].any?
        logger.warn("[morphosource:download_reviewer:export] #{summary[:unloadable].count} records were in " \
                    "Solr but not in Fedora: #{summary[:unloadable].join(', ')}")
      end

      return if summary[:unresolvable].empty?

      logger.warn("[morphosource:download_reviewer:export] #{summary[:unresolvable].count} Media resolve " \
                  "through a record that is in Solr but not in Fedora: #{summary[:unresolvable].join(', ')}")
    end

    def log(message)
      logger.info("[morphosource:download_reviewer:export] #{message}")
    end
  end
end
