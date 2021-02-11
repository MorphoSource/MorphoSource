module Morphosource
  module Works
    module IndexRelatedWorks

      def index_related_works
        case self
        when BiologicalSpecimen
          return unless Hyrax.config.index_related_works
          if organization_id_changed? || taxonomy_id_changed?
            index_related(media)
          end
        when CulturalHeritageObject
          return unless Hyrax.config.index_related_works
          if organization_id_changed?
            index_related(media)
          end
        when ImagingEvent
          return unless Hyrax.config.index_related_works
          if ie_modality_changed?
            index_related(media)
            index_related(objects)
          end
        when Media
          return unless Hyrax.config.index_related_works
          if (
            visibility_changed? || 
            fileset_accessibility_changed? ||
            media_type_changed? ||
            keyword_changed? ||
            member_of_public_collection_ids_changed?
          ) 
            index_related(objects)
          end
        when Organization
          if title_changed? || team_id_changed?
            if title_changed?
              index_related(media)
              index_related(physical_objects)
            end
            if team_id_changed?
              if !@old_collections.blank?
                index_related_collections(@old_collections)
              end
            end
            index_related_collections([team])
            index_related_collections(team&.child_projects)
          end
        when Taxonomy
          return unless Hyrax.config.index_related_works
          index_related(objects)
          index_related(media)
        end
      end

      private

        def index_related(works)
          return if works.blank? || works.first.blank?

          # collection causes argument error in test environment
          return if (works.first.collection? && Rails.env.test?)

          UpdateRelatedWorksIndexJob.perform_later(works)
        end

        def index_related_collections(collections)
          return if collections.nil?

          collections = collections.compact
          collections.each do |c|
            c.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
            c.update_index
          end
        end
    end
  end
end
