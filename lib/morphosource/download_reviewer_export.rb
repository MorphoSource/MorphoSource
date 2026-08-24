# frozen_string_literal: true

require 'csv'

module Morphosource
  ##
  # Read-only snapshot of what reviewer resolution returns today for every Media and
  # OrganizationCollection. The verification baseline for both backfills.
  #
  # @example
  #   Morphosource::DownloadReviewerExport.new(path: '/data/reviewers.csv').call
  class DownloadReviewerExport
    COLUMNS = %w[id model stored_download_reviewer resolved_reviewers manager_count].freeze

    # Joins multi-valued cells; ms_ids and Fedora ids never contain it.
    VALUE_SEPARATOR = '|'

    SCOPES = %w[all organizations media].freeze

    BATCH_SIZE = 1000

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
      logger.info("[morphosource:download_reviewer:export] writing #{scope} export to #{path}")

      write_export
      log_summary
      summary
    end

    # Shared by the log and the rake task's stdout so the two cannot disagree.
    #
    # @return [Array<String>]
    def summary_lines
      lines = ["export written to #{path} (scope: #{scope})"]

      if organizations?
        lines << "OrganizationCollections: #{summary[:organizations]} " \
                 "(#{summary[:organizations_with_stored_reviewer]} with a stored download_reviewer)"
        lines << "organizations with zero Managers: #{summary[:zero_manager_organizations].count}"
        summary[:zero_manager_organizations].each do |organization|
          lines << "  zero Managers: #{organization[:id]} #{organization[:title]}"
        end
      else
        lines << 'OrganizationCollections: not measured in this run'
      end

      lines << if media?
                 "Media: #{summary[:media]} (#{summary[:media_with_stored_reviewer]} with a stored download_reviewer)"
               else
                 'Media: not measured in this run'
               end

      lines << "CartItem rows: #{summary[:cart_items]}"
      lines << "in Solr but not in Fedora: #{summary[:unloadable].count}" if summary[:unloadable].any?
      lines
    end

    private

    # Renamed into place only once every read has succeeded, so a run that dies partway
    # leaves the previous export intact.
    def write_export
      temporary_path = "#{path}.#{Process.pid}.part"

      CSV.open(temporary_path, 'w') do |csv|
        csv << COLUMNS
        export_organizations(csv) if organizations?
        export_media(csv) if media?
      end
      summary[:cart_items] = CartItem.count

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

    # The deprecated Organization work keeps its own stored property and is deliberately absent.
    def export_organizations(csv)
      each_record(OrganizationCollection, 'has_model_ssim:OrganizationCollection') do |organization|
        summary[:organizations] += 1
        manager_count = organization.managers.count
        stored = Array(organization.download_reviewer).reject(&:blank?)
        summary[:organizations_with_stored_reviewer] += 1 if stored.any?

        if manager_count.zero?
          summary[:zero_manager_organizations] << { id: organization.id, title: Array(organization.title).first }
        end

        csv << [
          organization.id,
          'OrganizationCollection',
          join(stored),
          join(organization.media_download_reviewers),
          manager_count
        ]
      end
    end

    # Morphosource::Solr::Media includes MediaBehavior, so #reviewer here is what CartItem calls.
    def export_media(csv)
      each_solr_document('has_model_ssim:Media') do |media|
        summary[:media] += 1
        stored = Array(media.download_reviewer).reject(&:blank?)
        summary[:media_with_stored_reviewer] += 1 if stored.any?

        csv << [
          media.id,
          'Media',
          join(stored),
          join(media.reviewer),
          nil
        ]
      end
    end

    # Not find_each, which silently swallows records that are in Solr but gone from Fedora.
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

    # fl '*', not a whitelist: one that fell behind the resolver would resolve every
    # Media to its owner.
    def each_solr_document(query)
      each_solr_batch(query, '*') do |docs|
        docs.each do |doc|
          yield SolrDocument.new(doc)
          log_progress
        end
      end
    end

    # cursorMark, not start/rows: deep paging degrades at this size, and sorting on the
    # unique id keeps a record saved mid-walk from being visited twice.
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

    def join(values)
      Array(values).reject(&:blank?).join(VALUE_SEPARATOR)
    end

    def log_progress
      @processed = @processed.to_i + 1
      return unless (@processed % BATCH_SIZE).zero?

      logger.info("[morphosource:download_reviewer:export] #{@processed} records exported")
    end

    def new_summary
      {
        scope: scope,
        path: path,
        organizations: 0,
        organizations_with_stored_reviewer: 0,
        zero_manager_organizations: [],
        media: 0,
        media_with_stored_reviewer: 0,
        unloadable: [],
        cart_items: nil
      }
    end

    def log_summary
      summary_lines.each { |line| log(line) }

      return if summary[:unloadable].empty?

      logger.warn("[morphosource:download_reviewer:export] #{summary[:unloadable].count} records were in " \
                  "Solr but not in Fedora: #{summary[:unloadable].join(', ')}")
    end

    def log(message)
      logger.info("[morphosource:download_reviewer:export] #{message}")
    end
  end
end
