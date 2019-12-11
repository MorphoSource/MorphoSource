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
        # also get the device organization title and institution name for display
        organization_institution = ''
        organizations = Organization.where('member_ids_ssim' => id)
        if organizations.present?
          organization = organizations.first
          organization_institution = organization.title.first
          organization_institution += ' (' + organization.institution_name.first + ')' if organization.institution_name.present?
        end
        { 
          id: id, 
          label: title, 
          value: id,
          creator: creator,
          modality: modality,
          description: description,
          organization_institution: organization_institution
        }
      end
    end

    private

      def search_builder(controller)
        super
      end
  end
end