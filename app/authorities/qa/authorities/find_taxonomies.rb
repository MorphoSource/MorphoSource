module Qa::Authorities
  class FindTaxonomies < Qa::Authorities::FindWorks

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
        taxonomy_domain = doc.taxonomy_domain
        taxonomy_kingdom = doc.taxonomy_kingdom
        { id: id, label: title, value: id, taxonomy_domain: taxonomy_domain, taxonomy_kingdom: taxonomy_kingdom }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end