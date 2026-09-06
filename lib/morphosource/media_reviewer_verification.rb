# frozen_string_literal: true

module Morphosource
  # Temporary live-field and resolution comparison, meaningful only before ticket 5.
  class MediaReviewerVerification
    attr_reader :summary

    # @param logger [Logger]
    def initialize(logger: Rails.logger)
      @logger = logger
      @summary = new_summary
    end

    # @return [Hash] field differences, resolution differences and informational CartItem counts
    def call
      unless Media.instance_methods.include?(:download_reviewer=) && Media.instance_methods.include?(:reviewer)
        raise 'verify_media must run before the ticket 5 read-path cutover'
      end
      # The resolver otherwise creates this account on its first empty resolution.
      unless User.find_by_user_key(User.batch_user_key)
        raise 'The batch User must exist before running read-only Media reviewer verification'
      end

      @summary = new_summary
      MediaReviewerBatches.each do |ids|
        resolver = DownloadReviewerResolver.new
        resolutions = {}
        ids.each do |id|
          begin
            media = Media.find(id)
          rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
            summary[:unloadable] << id
            next
          end

          summary[:total] += 1
          verify_backfill(media)
          resolutions[id] = verify_resolution(media, resolver)
        end
        verify_cart_items(resolutions)
        log("processed #{summary[:total]} Media")
      end

      summary_lines.each { |line| log(line) }
      summary
    end

    # Differences are classified for review, never automatically waived.
    # @return [Boolean] whether the fields and resolutions agree for every indexed Media
    def verified?
      summary[:backfill_diffs].empty? && summary[:resolution_diffs].empty? && summary[:unloadable].empty?
    end

    # @return [Array<String>]
    def summary_lines
      lines = ["verified #{summary[:total]} Media", "backfill diffs: #{summary[:backfill_diffs].count}"]
      summary[:backfill_diffs].each do |diff|
        lines << "  #{diff[:id]}: record_download_reviewer_users #{diff[:expected].inspect} expected, " \
                 "#{diff[:actual].inspect} stored"
      end
      lines << "resolution diffs: #{summary[:resolution_diffs].count}"
      summary[:resolution_diffs].each do |diff|
        lines << "  #{diff[:id]} (#{diff[:reason]}): old #{diff[:expected].inspect}, new #{diff[:actual].inspect}"
      end
      lines << "in Solr but not in Fedora: #{summary[:unloadable].count}"
      summary[:unloadable].each { |id| lines << "  unloadable: #{id}" }
      lines << "CartItems checked: #{summary[:cart_items]}; differing reviewers: #{summary[:cart_item_diffs]} (informational)"
      lines
    end

    private

    def verify_backfill(media)
      stored = Array(media.download_reviewer).reject(&:blank?).uniq
      expected = stored.present? ? User.where(ms_id: stored).pluck(:ms_id) : []
      actual = Array(media.record_download_reviewer_users)
      return if expected.sort == actual.sort

      summary[:backfill_diffs] << { id: media.id, expected: expected, actual: actual }
    end

    def verify_resolution(media, resolver)
      expected = Array(media.reviewer).reject(&:blank?).uniq
      actual = resolver.call(media)
      if expected.sort != actual.sort
        summary[:resolution_diffs] << { id: media.id, expected: expected, actual: actual,
                                        reason: resolution_difference_reason(media, actual) }
      end
      actual
    end

    def resolution_difference_reason(media, actual)
      stored = Array(media.download_reviewer).reject(&:blank?)
      return :stored_organization if stored.any? && OrganizationCollection.exists?(id: stored)
      return :batch_user_fallback if actual == [User.batch_user_key]
      return :object_organization_mode if media.download_reviewer_mode == 'object_organization'

      :unexpected
    end

    def verify_cart_items(resolutions)
      CartItem.where(work_id: resolutions.keys).pluck(:work_id, :reviewers).each do |work_id, reviewers|
        summary[:cart_items] += 1
        summary[:cart_item_diffs] += 1 unless Array(reviewers).uniq.sort == resolutions.fetch(work_id).sort
      end
    end

    def new_summary
      { total: 0, backfill_diffs: [], resolution_diffs: [], unloadable: [], cart_items: 0, cart_item_diffs: 0 }
    end

    def log(message)
      @logger.info("[morphosource:download_reviewer:verify_media] #{message}")
    end
  end
end
