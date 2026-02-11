module Morphosource
  module ProjectBehavior
    extend ActiveSupport::Concern

    # Copy Media and Metadata to a new Media List
    def fork_to_list(user)
      list = copy_as_list(user)
      Morphosource::Collections::PermissionsCreateService.create_default(collection: list)
      copy_branding_info_to(list)
      copy_media_to(list)
      list
    rescue => e
      Rails.logger.error "Error forking Project #{id} to Media List: #{e.message}"
      raise e
    end

    def copy_as_list(user= depositor)
      MediaList.create(
        source_collection_ids: [id],
        title: title,
        depositor: user.user_key,
        creator: [user.user_key],
        description: description,
        based_near: based_near,
        related_url: related_url,
        representative_id: representative_id,
        thumbnail_id: thumbnail_id
      )
    end

    def copy_branding_info_to(list)
      branding_info = CollectionBrandingInfo.where(collection_id: id)
      branding_info.each do |info|
        local_path = copied_file_path(info, list)
        new_info = info.dup
        new_info.collection_id = list.id
        new_info.local_path = local_path
        new_info.save!
      end
    end

    def copy_media_to(list)
      AddCollectionMembersJob.perform_later(list.id, media_docs.map { |d| d['id'] } )
    end

    def copied_file_path(info, list)
      original_path = info.local_path
      new_path = original_path.sub("/opt/morphosource/root/", "/app/samvera/hyrax-webapp/")
                              .sub(id, list.id)

      FileUtils.mkdir_p(File.dirname(new_path))
      FileUtils.cp(original_path, new_path)
      new_path
    end
  end
end