module Morphosource
  module Works
    module IndexRelatedWorks
      attr_accessor :skip_index_related_works # disable related work indexing per object

      def index_related_works
        case self
        when BiologicalSpecimen
          return unless do_index_related?
          if organization_id_changed? || taxonomy_id_changed?
            index_related(media)
          end
        when CulturalHeritageObject
          return unless do_index_related?
          if organization_id_changed?
            index_related(media)
          end
        when Device
          return unless do_index_related?
          if (
            organization_id_changed? ||
            title_changed? ||
            creator_changed?
          )
            index_related(media)
          end
        when ImagingEvent
          return unless do_index_related?
          if ie_modality_changed?
            index_related(media)
          end
          if physical_object_id_changed?
            old_objects =
              BiologicalSpecimen.where(related_media_ids_ssim: media.map(&:id)) +
              CulturalHeritageObject.where(related_media_ids_ssim: media.map(&:id)) -
              objects
            index_related(media + objects + old_objects) # a bit inefficient but getting old values is a nightmare and order of index updates is important
          end
        when Media
          return unless do_index_related?
          if (
            visibility_changed? ||
            fileset_accessibility_changed? ||
            media_type_changed? ||
            keyword_changed? ||
            member_of_public_collection_ids_changed?
          )
            index_related(objects)
          end
          if related_media_ids_changed?
            index_related(objects)
            index_related(related_media)
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
        when OrganizationCollection
          return unless title_changed?

          index_related(media)
          index_related(physical_objects)
          index_related_collections(child_projects)
        when Taxonomy
          return unless do_index_related?
          index_related(objects)
          index_related(media)
        end
      end

      private

        def do_index_related?
          Hyrax.config.index_related_works && !skip_index_related_works
        end

        def index_related(works)
          return if works.blank? || works.first.blank?

          # collection causes argument error in test environment
          return if (works.first.collection? && Rails.env.test?)

          UpdateRelatedWorksIndexJob.perform_later(works.compact.map { |w| w.id })
        end

        def index_related_collections(collections)
          return if collections.nil?

          collections = collections.compact
          collections.each do |c|
            c.update_index
          end
        end
    end
  end
end
