module Qa::Authorities
  class FindInstitutions < Qa::Authorities::FindWorks

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
        institution_code = doc.institution_code
        { id: id, label: title, value: id, institution_code: institution_code }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end