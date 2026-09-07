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
        payload = event.respond_to?(:payload) ? event.payload : {}
        object = payload[:object]

        log_non_resource(event) && return unless object.is_a?(Valkyrie::Resource)
        log_skip_reindex(event) && return if payload[:skip_index_related_works]

        case object
        when TaxonomyResource
          index_all(object.objects)
          index_all(object.media)
        when DeviceResource
          index_all(object.media)
        when ImagingEventResource
          media = object.media
          current_objects = object.objects
          old_objects = find_old_imaging_event_objects(media, current_objects)
          index_all(media + current_objects + old_objects)
        end

      end

      private

      def log_non_resource(event)
        payload = event.respond_to?(:payload) ? event.payload : {}
        Hyrax.logger.info('Skipping related work reindex because the object ' \
                          "#{payload[:object]} was not a Valkyrie::Resource.")
      end

      def log_skip_reindex(event)
        Hyrax.logger.info('Skipping related work reindex because skip reindex flag was present.')
      end

      def find_old_imaging_event_objects(media, current_objects)
        media_ids = media.map { |m| m.id.to_s }
        return [] if media_ids.blank?

        (BiologicalSpecimen.where(related_media_ids_ssim: media_ids) +
         CulturalHeritageObject.where(related_media_ids_ssim: media_ids)) - current_objects
      end

      def index_all(works)
        return if works.blank? || works.first.blank?

        # collection causes argument error in test environment
        return if (works.first.collection? && Rails.env.test?)

        UpdateRelatedWorksIndexJob.perform_later(works.compact.map { |w| w.id.to_s })
      end
    end
  end
end
