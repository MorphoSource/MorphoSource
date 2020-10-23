module Qa::Authorities
  class FindMedia < Qa::Authorities::FindWorks
    self.search_builder_class = Morphosource::My::FindMediaSearchBuilder

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.title
        object_title = Media.find(doc.id).physical_objects&.first&.title
        { id: id, label: title, value: id, object_title: object_title }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end