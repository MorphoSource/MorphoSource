# Module for methods held in common between web and batch submission
# Todo: move more logic into this module
module SubmissionsControllerBehavior
  def get_organizations_and_devices
    get_device_organizations_and_devices
    get_null_organization
    get_object_organizations
  end

  def get_device_organizations_and_devices
    @device_organizations = repository.search(device_organizations_search_builder.query)["response"]["docs"]
    @device_organizations_hash = @device_organizations.map do |o|
      [
        o['id'], 
        {
          id: o['id'],
          text: "#{[o['institution_name_tesim']&.first, o['title_tesim']&.first].compact.join(', ')} (#{o['institution_code_tesim']&.join('/')}:#{o['collection_code_tesim']&.join('/')})",
          organization_type: o['organization_type_tesim']&.first,
          institution_name: o['institution_name_tesim']&.first,
          title: o['title_tesim']&.first,
          institution_code: o['institution_code_tesim']&.join(', '),
          collection_code: o['collection_code_tesim']&.join(', '),
          recordset_id: o['recordset_id_tesim']&.join(', '),
          related_url: o['related_url_tesim']&.first,
          address: o['address_tesim']&.first,
          city: o['city_tesim']&.first,
          state_province: o['state_province_tesim']&.first,
          country: o['country_tesim']&.first,
          postal_code: o['postal_code_tesim']&.first,
          description: o['description_tesim']&.first,
          contact_person: o['contact_person_tesim']&.first,
          devices: o['member_ids_ssim'] || [],
          data_manager: o['data_manager_tesim']&.first
        }
      ]
    end.to_h
    
    
    # Get devices and add devices with .organization_id relationship to device orgs select2 data
    @devices = Device.all_solr
    @devices_with_ids = @devices.map do |d|
      if (organization_id = d['organization_id_ssim']&.first).present?
        org_devices = @device_organizations_hash[organization_id][:devices]
        org_devices << d['id'] unless org_devices.include?(d['id'])
      end

      [
        d['id'], 
        {
          id: d['id'],
          text: [d['creator_tesim']&.first, d['title_tesim']&.first].compact.join(' '),
          title: d['title_tesim']&.first,
          creator: d['creator_tesim']&.first,
          modality: d['modality_tesim']&.join(','),
          description: d['description_tesim']&.first,
          organization_id: d['organization_id_ssim']&.first
        }
      ]
    end.to_h
    if !current_user.admin?
      @devices_with_ids.delete(Hyrax.config.unknown_ct_scanner)
    end

    @device_organizations_select2 = @device_organizations_hash.values
  end

  def get_null_organization
    if Hyrax.config.null_organization_id.present? && Organization.exists?(Hyrax.config.null_organization_id)
      o = Organization.find(Hyrax.config.null_organization_id)
      @null_organization = {
        id: o.id,
        text: "#{[o.institution_name&.first, o.title&.first].compact.join(', ')} (#{o.institution_code&.join('/')}:#{o.collection_code&.join('/')})",
        organization_type: o.organization_type&.first,
        institution_name: o.institution_name&.first,
        title: o.title&.first,
        institution_code: o.institution_code&.join(', '),
        collection_code: o.collection_code&.join(', '),
        related_url: o.related_url&.first,
        address: o.address&.first,
        city: o.city&.first,
        state_province: o.state_province&.first,
        country: o.country&.first,
        postal_code: o.postal_code&.first,
        description: o.description&.first,
        contact_person: o.contact_person&.first,
        devices: o.member_ids || []
      }

      # Catch any device.organization_id relationships to null organization
      ( @devices_with_ids || {} ).select do |id, attributes|
        if attributes[:organization_id] == o.id
          @null_organization[:devices] << id unless @null_organization[:devices].includes?(id)
        end
      end
    else
      @null_organization = {}
    end
  end

  def get_object_organizations
    @object_organizations = repository.search(object_organizations_search_builder.query)["response"]["docs"]
    @object_organizations_select2 = @object_organizations.map do |o|
      {
        id: o['id'],
        text: "#{[o['institution_name_tesim']&.first, o['title_tesim']&.first].compact.join(', ')} (#{o['institution_code_tesim']&.join('/')}:#{o['collection_code_tesim']&.join('/')})",
        organization_type: o['organization_type_tesim']&.first,
        institution_name: o['institution_name_tesim']&.first,
        title: o['title_tesim']&.first,
        institution_code: o['institution_code_tesim']&.join(', '),
        collection_code: o['collection_code_tesim']&.join(', '),
        recordset_id: o['recordset_id_tesim']&.join(', '),
        related_url: o['related_url_tesim']&.first,
        address: o['address_tesim']&.first,
        city: o['city_tesim']&.first,
        state_province: o['state_province_tesim']&.first,
        country: o['country_tesim']&.first,
        postal_code: o['postal_code_tesim']&.first,
        description: o['description_tesim']&.first,
        contact_person: o['contact_person_tesim']&.first,
        devices: o['member_ids_ssim'],
        data_manager: o['data_manager_tesim']&.first
      }
    end
  end
end