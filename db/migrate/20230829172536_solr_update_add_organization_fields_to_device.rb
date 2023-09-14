class SolrUpdateAddOrganizationFieldsToDevice < ActiveRecord::Migration[5.2]
  def up
    # Get organization solr docs and create mapping to devices
    organization_docs = ActiveFedora::SolrService.query("has_model_ssim:Organization", rows: 999_999)
    device_id_to_organizations = {}
    ( organization_docs || [] ).each do |org_doc|
      ( org_doc["member_ids_ssim"] || [] ).each do |device_id|
        device_id_to_organizations[device_id] = org_doc
      end
    end

    # Update device docs if possible
    device_docs = ActiveFedora::SolrService.query("has_model_ssim:Device", rows: 999_999)
    ( device_docs || [] ).each do |doc|
      new_doc = doc.to_h

      if (device_org = device_id_to_organizations[doc["id"]]).present?
        new_doc["device_organization_id_tesim"] = device_org["id"]
        new_doc["device_organization_id_ssim"] = device_org["id"]
        new_doc["device_organization_title_tesim"] = device_org["title_tesim"]
        new_doc["device_organization_title_ssi"] = device_org["title_ssi"]
        new_doc["device_organization_institution_name_tesim"] = device_org["institution_name_tesim"]
        new_doc["device_organization_institution_name_ssim"] = device_org["institution_name_ssim"]

        # Commit new_doc to Solr
        ActiveFedora::SolrService.add(new_doc, softCommit: true)
      end
    end
  end

  def down
    device_docs = ActiveFedora::SolrService.query("has_model_ssim:Device", rows: 999_999)
    ( device_docs || [] ).each do |doc|
      new_doc = doc.to_h

      new_doc["device_organization_id_tesim"] = nil
      new_doc["device_organization_id_ssim"] = nil
      new_doc["device_organization_title_tesim"] = nil
      new_doc["device_organization_title_ssi"] = nil
      new_doc["device_organization_institution_name_tesim"] = nil
      new_doc["device_organization_institution_name_ssim"] = nil

      # Commit new_doc to Solr
      ActiveFedora::SolrService.add(new_doc, softCommit: true)
    end
  end
end
