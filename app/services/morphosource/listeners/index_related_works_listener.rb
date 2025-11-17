# frozen_string_literal: true

module Morphosource
  module Listeners
    ##
    # Reindexes works related to an updated work, in situations where work indices are interrelated.
    #
    # This is a pub-sub re-implementation of the MS3 module Morphosource::Works::IndexRelatedWorks.
    #
    # @note Unlike in IndexRelatedWorks, we can't turn off reindexing for a single object. Because
    #   of this, it's very important to be careful to avoid circular unconditional update loops
    #   (work A updates all work B which update all work A...). For now also not re-implementing
    #   Hyrax config-level ability to turn off reindexing, since it's critical for app functionality.
    #
    # @note This listener makes no attempt to avoid reindexing when no metadata
    #   has actually changed, or when real metadata changes won't impact the
    #   indexed data. We trust that published metadata update events represent
    #   actual changes to object metadata, and that the indexing adapter
    #   optimizes reasonably for actual index document contents.
    class IndexRelatedWorksListener
      ##
      # Re-index related resources.
      #
      # @param event [Dry::Event]
      def on_object_metadata_updated(event)
        log_non_resource(event) && return unless event[:object].is_a?(Valkyrie::Resource)

        case event[:object]
        when TaxonomyResource
          index_all(event[:object].objects)
          index_all(event[:object].media)
        end

      end

      private

      def log_non_resource(event)
        Hyrax.logger.info('Skipping object reindex because the object ' \
                          "#{event[:object]} was not a Valkyrie::Resource.")
      end

      def index_all(works)
        return if works.blank? || works.first.blank?

        # collection causes argument error in test environment
        return if (works.first.collection? && Rails.env.test?)

        UpdateRelatedWorksIndexJob.perform_later(works.compact.map { |w| w.id })
      end
    end
  end
end