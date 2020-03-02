module Qa::Authorities
  class FindParentMediaToAdd < Qa::Authorities::FindWorks

    include MorphosourceHelper
    include Morphosource::PresenterMethods

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      # exclude the media itself and child media
      current_media_id = controller.request.parameters['current_media_id']
      current_media = Media.where('id' => current_media_id).first
      exclude_list = [current_media_id] + child_media_ids(current_media, 5, []).flatten.uniq
      docs = response.documents
      docs.map do |doc|
        unless exclude_list.include?(doc.id) 
          id = doc.id
          title = doc.title
          { id: id, label: title, value: id }
        end
      end.compact
    end

    private

      def search_builder(controller)
        super
      end
  end
end