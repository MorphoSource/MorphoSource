module Morphosource
  # Applies missing permissions to a media and its related works
    # all works
    # - edit access to the admin group
    # - edit access to the user with ownership
    # open download media and all other work types:
    # - read access to public
    # media
    # - applies collection permissions
  # Does not remove any permissions that are already present
  # if update_hierarchy is true, default permissions are also applied to its related works
  # if a media is missing a physical object, the job will attempt to repair the links between the media and its related works
  class ApplyPermissionsJob < Hyrax::ApplicationJob

    queue_as Hyrax.config.update_medium_queue_name

    def perform(media_id: nil, update_hierarchy: nil)
      @media = Media.find(media_id)
      update_permissions(related_works) if update_hierarchy
      update_permissions(@media)
    end

    def related_works
      # a media without a physical object may be missing links to its related works
      if @media.to_solr["physical_object_id_ssim"].blank?
        Morphosource::DataCuration::RelationshipRepairService.new.send(:repair_hierarchy, @media.id)
      end
      # Return an array containing events and physical objects
      @media.ancestors + @media.physical_objects
    end

    def update_permissions(works)
      works = Array(works)
      works.each do |work|
        work.edit_users += [work.user_with_ownership]
        work.edit_groups += ['admin']
        if work.is_a? Media
          apply_collection_permissions(work)
          if work.fileset_visibility == ['open']
            work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          end
          work.save!
          InheritPermissionsJob.perform_later(work)
        else
          work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          work.save!
        end
      end
    end

    def apply_collection_permissions(media)
      collection_ids = media.member_of_collection_ids
      collection_ids.each do |id|
        next unless SolrDocument.where({'id' => id})&.first&.media_inherit_permissions?
        next unless template = Hyrax::PermissionTemplate.find_by!(source_id: id)
        Hyrax::PermissionTemplateApplicator.apply(template).to(model: media)
      end
    end
  end
end