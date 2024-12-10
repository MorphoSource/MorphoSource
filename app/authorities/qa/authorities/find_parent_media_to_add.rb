module Qa::Authorities
  class FindParentMediaToAdd < Qa::Authorities::FindMedia

    include MorphosourceHelper
    include Morphosource::PresenterMethods

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.blacklight_config.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      # exclude the media itself and child media
      current_media_id = controller.request.parameters['current_media_id']
      current_media = Media.where('id' => current_media_id).first
      exclude_list = [current_media_id] + current_media.child_media_ids
      docs = response.documents
      docs.map do |doc|
        unless exclude_list.include?(doc.id) 
          id = doc.id
          title = doc.title
          object_title = Media.find(doc.id).physical_objects&.first&.title
          { id: id, label: title, value: id, object_title: object_title }
        end
      end.compact
    end

    private

      def search_builder(controller)
        super
      end
  end
end