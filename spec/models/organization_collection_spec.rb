# frozen_string_literal= true
require 'rails_helper'

RSpec.describe OrganizationCollection, type: :model do

  it "is valid with valid attributes" do
    subject.address = ['26 Oxford Street']
    subject.agreement_uri = ['https://mcz.harvard.edu/permissions-copyright']
    subject.allowed_remote_source = false
    subject.can_submit_remote_files = false
    subject.city = ['Cambridge']
    subject.collection_code = ['sc']
    subject.collection_type_gid = organization_collection_type.gid
    subject.contact_person = ['Pam Beasley pam@beasley.com']
    subject.country = ['United States']
    subject.creator = ['Donald Duck']
    subject.contributor = ['Mickey Mouse']
    subject.data_manager = ['f95e50']
    subject.depositor = '1234'
    subject.description = ['lorem ipsum']
    subject.download_permission = ['restricted_download']
    subject.download_reviewer = ['2956']
    subject.institution_code = ['mcz']
    subject.institution_name = ['Harvard University']
    subject.license = ['https=//creativecommons.org/licenses/by-nc-nd/4.0/']
    subject.license_blank = ['0']
    subject.media_ownership_transfer = false
    subject.morphosource_use_agreement_type = ['Standard']
    subject.organization_type = ['Museum, Department, or Lab Collection']
    subject.postal_code = ['02138']
    subject.permissions_enforcement_mode = ['Recommend']
    subject.permits_3d_use = ['3DPrintingLimited']
    subject.permits_commercial_use = ['CommercialUseNotPermitted']
    subject.publisher = ['Museum of Comparative Zoology, Harvard University']
    subject.preview_mode = ['Interactive/Embeddable']
    subject.recordset_id = ['1234132414adsfsad']
    subject.related_url = ['https=//mcz.harvard.edu/special-collections']
    subject.required_archival_of_published_derivatives = ['OnMorphoSource']
    subject.rights_holder = ['President and Fellows of Harvard College (Copyright and License)']
    subject.rights_holder_blank = ['0']
    subject.rights_statement = ['http=//rightsstatements.org/vocab/InC/1.0/']
    subject.rights_statement_blank = ['0']
    subject.state_province = ['Massachusetts']
    subject.title = ['collection organization']

    expect(subject).to be_valid
  end

  describe 'collection_type' do
    it 'has the organization collection type' do
      expect(described_class.collection_type).to eq(organization_collection_type)
      expect(subject.collection_type).to eq(organization_collection_type)
      expect(subject.human_readable_type).to eq('Organization')
    end
  end
end
