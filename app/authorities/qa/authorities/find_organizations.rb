module Qa::Authorities
  class FindOrganizations < Qa::Authorities::FindWorks

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
        organization_type = doc.organization_type
        institution_code = doc.institution_code
        institution_name = doc.institution_name
        collection_code = doc.collection_code
        recordset_id = doc.recordset_id
        description = doc.description
        address = doc.address
        city = doc.city
        state_province = doc.state_province
        country = doc.country
        { id: id, label: title, value: id, organization_type: organization_type, institution_code: institution_code, institution_name: institution_name, collection_code: collection_code, recordset_id: recordset_id, description: description, address: address, city: city, state_province: state_province, country: country }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end