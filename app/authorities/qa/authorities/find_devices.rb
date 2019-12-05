module Qa::Authorities
  class FindDevices < Qa::Authorities::FindWorks

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
        creator = doc.creator
        modality = doc.modality
        description = doc.description
        { 
          id: id, 
          label: title, 
          value: id,
          creator: creator,
          modality: modality,
          description: description
        }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end