module Qa::Authorities
  # Find organization and include device information with organization output
  class FindOrganizationsWithDevices < Qa::Authorities::FindWorks
    self.search_builder_class = Morphosource::FindOrganizationsSearchBuilder

    include MorphosourceHelper

    def search(_q, controller)
      # The My::FindWorksSearchBuilder expects a current_user
      return [] unless controller.current_user
      repo = CatalogController.new.repository
      builder = search_builder(controller)
      response = repo.search(builder)
      docs = response.documents
      docs.map do |doc|
        id = doc.id
        title = doc.institution_name.present? ? [ doc.institution_name&.first + ', ' + doc.title&.first ] : doc.title
        organization_type = doc.organization_type
        institution_code = doc.institution_code
        institution_name = doc.institution_name
        collection_code = doc.collection_code
        recordset_id = doc.recordset_id
        description = doc.description
        related_url = doc.related_url
        address = doc.address
        city = doc.city
        state_province = doc.state_province
        postal_code = doc.postal_code
        country = doc.country
        devices = organization_devices(id)
        { id: id, label: title, value: id, organization_type: organization_type, institution_code: institution_code, institution_name: institution_name, collection_code: collection_code, recordset_id: recordset_id, description: description, related_url: related_url, address: address, city: city, state_province: state_province, postal_code: postal_code, country: country, devices: devices }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end
