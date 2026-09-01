# Can be removed after the Morphosource download reviewer migration is complete and the rake task is no longer needed.
# frozen_string_literal: true

module Morphosource
  # Verifies that the backfill of custom_download_reviewer_users was correct
  # @example
  #   Morphosource::OrganizationReviewerVerification.new.call
  class OrganizationReviewerVerification
    QUERY = 'has_model_ssim:OrganizationCollection'

    MANAGERS_ARE_DOWNLOAD_REVIEWERS =
      ::RDF::URI.new('https://www.morphosource.org/terms/managersAreDownloadReviewers').freeze

    attr_reader :logger, :summary

    # @param logger [Logger]
    def initialize(logger: Rails.logger)
      @logger = logger
      @summary = new_summary
    end

    # @return [Hash] the summary, with :backfill_diffs and :resolution_diffs
    def call
      @summary = new_summary
      log('verifying the backfill, then comparing download_reviewers against media_download_reviewers')

      each_organization do |organization|
        verify_backfill(organization)
        verify_resolution(organization)
      end

      log_summary
      summary
    end

    # @return [Boolean] true when nothing moved and every indexed organization loaded
    def verified?
      summary[:backfill_diffs].empty? && summary[:resolution_diffs].empty? && summary[:unloadable].empty?
    end

    # @return [Array<String>]
    def summary_lines
      lines = ["verified #{summary[:total]} organizations"]
      lines << "backfill diffs: #{summary[:backfill_diffs].count}"
      summary[:backfill_diffs].each do |diff|
        lines << "  #{diff[:id]}: managers_are_download_reviewers #{diff[:expected_mode].inspect} " \
                 "expected, #{diff[:actual_mode].inspect} stored; custom_download_reviewer_users " \
                 "#{diff[:expected_users].inspect} expected, #{diff[:actual_users].inspect} stored"
      end
      lines << "resolution diffs: #{summary[:resolution_diffs].count}"
      summary[:resolution_diffs].each do |diff|
        lines << "  #{diff[:id]}: media_download_reviewers #{diff[:expected].inspect}, " \
                 "download_reviewers #{diff[:actual].inspect}"
      end
      lines << "in Solr but not in Fedora: #{summary[:unloadable].count}"
      summary[:unloadable].each { |id| lines << "  unloadable: #{id}" }
      lines
    end

    private

    def verify_backfill(organization)
      stored = Array(organization.download_reviewer).reject(&:blank?)
      expected_users = stored.present? ? User.where(ms_id: stored).pluck(:ms_id) : []
      actual_users = Array(organization.custom_download_reviewer_users).reject(&:blank?)
      expected_mode = expected_users.empty?
      actual_mode = stored_managers_flag(organization)
      return if expected_mode == actual_mode && expected_users.sort == actual_users.sort

      summary[:backfill_diffs] << { id: organization.id,
                                    expected_mode: expected_mode, actual_mode: actual_mode,
                                    expected_users: expected_users, actual_users: actual_users }
    end

    # The reader answers true for a blank field
    # Reads the triple instead
    def stored_managers_flag(organization)
      organization.resource
                  .query([organization.rdf_subject, MANAGERS_ARE_DOWNLOAD_REVIEWERS, nil])
                  .to_a.first&.object&.object
    end

    def verify_resolution(organization)
      expected = Array(organization.media_download_reviewers).reject(&:blank?)
      actual = Array(organization.download_reviewers).reject(&:blank?)
      return if expected.sort == actual.sort

      summary[:resolution_diffs] << { id: organization.id, expected: expected, actual: actual }
    end

    def each_organization
      ActiveFedora::SolrService.query(QUERY, rows: 999_999).each do |doc|
        begin
          organization = OrganizationCollection.find(doc['id'])
        rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
          # Deleted from Fedora, delete never reached Solr. Nothing to compare.
          summary[:unloadable] << doc['id']
          logger.warn("#{log_prefix} #{doc['id']} is in Solr but not in Fedora; skipped")
          next
        end

        summary[:total] += 1
        yield organization
      end
    end

    def new_summary
      { total: 0, backfill_diffs: [], resolution_diffs: [], unloadable: [] }
    end

    def log_summary
      summary_lines.each { |line| log(line) }
    end

    def log(message)
      logger.info("#{log_prefix} #{message}")
    end

    def log_prefix
      '[morphosource:download_reviewer:verify_organizations]'
    end
  end
end
