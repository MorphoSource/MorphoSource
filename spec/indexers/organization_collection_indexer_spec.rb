require 'rails_helper'

RSpec.describe OrganizationCollectionIndexer do
  subject(:solr_document) { OrganizationCollectionIndexer.new(organization).generate_solr_document }
  let(:user)              { FactoryBot.create(:contributor) }
  let(:organization)      { FactoryBot.create(:organization_collection, id: 'abcdef',
                                                                        address: ['26 Oxford Street'],
                                                                        agreement_uri: ['https://mcz.harvard.edu/permissions-copyright'],
                                                                        allowed_remote_source: false,
                                                                        can_submit_remote_files: false,
                                                                        city: ['Cambridge'],
                                                                        collection_code: ['sc'],
                                                                        collection_type_gid: organization_collection_type.to_global_id,
                                                                        contact_person: ['Pam Beasley pam@beasley.com'],
                                                                        country: ['United States'],
                                                                        creator: ['Donald Duck'],
                                                                        contributor: ['Mickey Mouse'],
                                                                        data_manager: ['f95e50'],
                                                                        depositor: user.ms_id,
                                                                        description: ['lorem ipsum'],
                                                                        download_permission: ['restricted_download'],
                                                                        download_reviewer: ['2956'],
                                                                        institution_code: ['mcz'],
                                                                        institution_name: ['Harvard University'],
                                                                        license: ['https://creativecommons.org/licenses/by-nc-nd/4.0/'],
                                                                        license_blank: ['0'],
                                                                        media_ownership_transfer: false,
                                                                        morphosource_use_agreement_type: ['Standard'],
                                                                        organization_type: ['Museum, Department, or Lab Collection'],
                                                                        postal_code: ['02138'],
                                                                        permissions_enforcement_mode: ['Recommend'],
                                                                        permits_3d_use: ['3DPrintingLimited'],
                                                                        permits_commercial_use: ['CommercialUseNotPermitted'],
                                                                        publisher: ['Museum of Comparative Zoology, Harvard University'],
                                                                        preview_mode: ['Interactive/Embeddable'],
                                                                        recordset_id: ['1234132414adsfsad'],
                                                                        related_url: ['https://mcz.harvard.edu/special-collections'],
                                                                        required_archival_of_published_derivatives: ['OnMorphoSource'],
                                                                        rights_holder: ['President and Fellows of Harvard College (Copyright and License)'],
                                                                        rights_holder_blank: ['0'],
                                                                        rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'],
                                                                        rights_statement_blank: ['0'],
                                                                        state_province: ['Massachusetts'],
                                                                        ark: ["ark:/12345/m4/678910"],
                                                                        title: ['organization collection']) }


  before do
    organization.managers << user
    organization.managers_group.save
  end

  it 'indexes needed fields' do
    expect(solr_document[:id]).to eq(organization.id)
    expect(solr_document['address_tesim']).to match_array(organization.address)
    expect(solr_document['agreement_uri_tesim']).to match_array(organization.agreement_uri)
    expect(solr_document['city_tesim']).to match_array(organization.city)
    expect(solr_document['city_ssim']).to match_array(organization.city)
    expect(solr_document['collection_code_sim']).to match_array(organization.collection_code)
    expect(solr_document['collection_code_tesim']).to match_array(organization.collection_code)
    expect(solr_document['collection_type_gid_ssim']).to  match_array(organization.collection_type.to_global_id.to_s)
    expect(solr_document['contact_person_sim']).to match_array(organization.contact_person)
    expect(solr_document['contact_person_tesim']).to match_array(organization.contact_person)
    expect(solr_document['contributor_sim']).to match_array(organization.contributor)
    expect(solr_document['contributor_tesim']).to match_array(organization.contributor)
    expect(solr_document['country_sim']).to match_array(organization.country)
    expect(solr_document['country_tesim']).to match_array(organization.country)
    expect(solr_document['country_ssim']).to match_array(organization.country)
    expect(solr_document['creator_sim']).to match_array(organization.creator)
    expect(solr_document['creator_tesim']).to match_array(organization.creator)
    expect(solr_document['data_manager_tesim']).to match_array(organization.data_manager)
    expect(solr_document['data_manager_ssim']).to match_array(organization.data_manager)
    expect(solr_document['depositor_ssim']).to match_array(organization.depositor)
    expect(solr_document['depositor_tesim']).to match_array(organization.depositor)
    expect(solr_document['description_tesim']).to match_array(organization.description)
    expect(solr_document['download_permission_tesim']).to match_array(organization.download_permission)
    expect(solr_document['download_reviewer_tesim']).to match_array(organization.download_reviewer)
    expect(solr_document['generic_type_sim']).to match_array(['Collection'])
    expect(solr_document['has_model_ssim']).to match_array(organization.class.to_s)
    expect(solr_document['institution_code_tesim']).to match_array(organization.institution_code)
    expect(solr_document['institution_code_ssim']).to match_array(organization.institution_code)
    expect(solr_document['institution_name_ssim']).to match_array(organization.institution_name)
    expect(solr_document['institution_name_tesim']).to match_array(organization.institution_name)
    expect(solr_document['license_blank_tesim']).to match_array(organization.license_blank)
    expect(solr_document['license_tesim']).to match_array(organization.license)
    expect(solr_document['media_ownership_transfer_bsi']).to eq(organization.media_ownership_transfer)
    expect(solr_document['morphosource_use_agreement_type_tesim']).to match_array(organization.morphosource_use_agreement_type)
    expect(solr_document['organization_type_sim']).to match_array(organization.organization_type)
    expect(solr_document['organization_type_tesim']).to match_array(organization.organization_type)
    expect(solr_document['organization_type_ssim']).to match_array(organization.organization_type)
    expect(solr_document['permissions_enforcement_mode_tesim']).to match_array(organization.permissions_enforcement_mode)
    expect(solr_document['permits_3d_use_tesim']).to match_array(organization.permits_3d_use)
    expect(solr_document['permits_commercial_use_tesim']).to match_array(organization.permits_commercial_use)
    expect(solr_document['postal_code_tesim']).to match_array(organization.postal_code)
    expect(solr_document['preview_mode_tesim']).to match_array(organization.preview_mode)
    expect(solr_document['publisher_sim']).to match_array(organization.publisher)
    expect(solr_document['publisher_tesim']).to match_array(organization.publisher)
    expect(solr_document['recordset_id_sim']).to match_array(organization.recordset_id)
    expect(solr_document['recordset_id_tesim']).to match_array(organization.recordset_id)
    expect(solr_document['related_url_tesim']).to match_array(organization.related_url)
    expect(solr_document['required_archival_of_published_derivatives_tesim']).to match_array(organization.required_archival_of_published_derivatives)
    expect(solr_document['rights_holder_blank_tesim']).to match_array(organization.rights_holder_blank)
    expect(solr_document['rights_holder_tesim']).to match_array(organization.rights_holder)
    expect(solr_document['rights_statement_blank_tesim']).to match_array(organization.rights_statement_blank)
    expect(solr_document['rights_statement_tesim']).to match_array(organization.rights_statement)
    expect(solr_document['state_province_tesim']).to match_array(organization.state_province)
    expect(solr_document['state_province_ssim']).to match_array(organization.state_province)
    expect(solr_document['title_sim']).to match_array(organization.title)
    expect(solr_document['title_ssi']).to eq(organization.title.first)
    expect(solr_document['title_tesim']).to match_array(organization.title)
    expect(solr_document['visibility_ssi']).to eq(organization.visibility)
    expect(solr_document['ark_ssim']).to match_array(organization.ark)
    expect(solr_document['ark_tesim']).to match_array(organization.ark)
  end
end
