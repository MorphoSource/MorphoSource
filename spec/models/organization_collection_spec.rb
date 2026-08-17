# frozen_string_literal= true
require 'rails_helper'

RSpec.describe OrganizationCollection, type: :model do

  # NB: create_organization_project callback is disabled in the organization_collection factory

  let(:user)  { FactoryBot.create(:contributor) }

  it "is valid with valid attributes" do
    subject.address = ['26 Oxford Street']
    subject.agreement_uri = ['https://mcz.harvard.edu/permissions-copyright']
    subject.allowed_remote_source = false
    subject.can_submit_remote_files = false
    subject.city = ['Cambridge']
    subject.collection_code = ['sc']
    subject.collection_type_gid = organization_collection_type.to_global_id
    subject.contact_person = ['Pam Beasley pam@beasley.com']
    subject.country = ['United States']
    subject.creator = ['Donald Duck']
    subject.contributor = ['Mickey Mouse']
    subject.data_manager = ['f95e50']
    subject.date_managed = '2023-10-01'
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

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe '#create_organization_project' do
    let(:organization)  { FactoryBot.create(:organization_collection, title: ['factory bot organization'], depositor: user.ms_id)}

    before do
      allow(Collection).to receive(:find).and_call_original
    end

    it 'creates a project with the correct metadata' do
      project = organization.send(:create_organization_project)
      expect(project.title).to eq([I18n.t('morphosource.dashboard.collections.organization_collection.example_project.title', title: organization.title.first)])
      expect(project.description).to eq([I18n.t('morphosource.dashboard.collections.organization_collection.example_project.description')])
      expect(project.visibility).to eq('restricted')
      expect(project.depositor).to eq(user.ms_id)
      expect(organization.child_projects).to include(project)
    end
  end

  describe '#create_collection_groups' do
    let!(:organization) { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

    it 'assigns them names with the collection id' do
      group_names = Role.all.map(&:name)
      Collection::DEFAULT_GROUP_ROLES.each do |role|
        expect(group_names).to include("#{organization.id}_#{role}")
      end
    end

    it 'adds the depositor as a manager' do
      expect(organization.managers).to eq([user])
      expect(organization.date_managed).to eq(Date.today)
    end

    context 'when the depositor is an admin' do
      let(:admin) { FactoryBot.create(:admin) }

      it 'does not mark the organization as managed' do
        org = FactoryBot.create(:organization_collection, depositor: admin.ms_id)
        expect(org.managers).to eq([admin])
        expect(org.date_managed).to be_nil
      end
    end
  end

  describe 'persisting the derived management date' do
    it 'writes the date without re-entering the ark status callback' do
      expect_any_instance_of(described_class).not_to receive(:update_ark_status)
      org = FactoryBot.create(:organization_collection, depositor: user.ms_id)
      expect(org.date_managed).to eq(Date.today)
    end
  end

  describe '#can_manage_devices?' do
    let!(:organization) { FactoryBot.create(:organization_collection, depositor: user.ms_id, organization_type: organization_type) }

    context 'organization_type is not set' do
      let(:organization_type) { [] }
      it { expect(organization.can_manage_devices?).to be(false) }
    end

    context 'organization_type is ["Museum, Department, or Lab Collection"]' do
      let(:organization_type) { ["Museum, Department, or Lab Collection"] }
      it { expect(organization.can_manage_devices?).to be(false) }
    end

    context 'organization_type is ["Scanning Facility"]' do
      let(:organization_type) { ["Scanning Facility"] }
      it { expect(organization.can_manage_devices?).to be(true) }
    end

    context 'organization_type is ["Collection and Scanning Facility"]' do
      let(:organization_type) { ["Collection and Scanning Facility"] }
      it { expect(organization.can_manage_devices?).to be(true) }
    end
  end

  describe 'record_date_managed' do
    let!(:organization) { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

    context 'collection does not have managers' do
      before do
        organization.managers_group.users = []
        organization.managers_group.save!
        organization.date_managed = nil
      end

      context 'collection has a date_managed' do
        before do
          organization.date_managed = Date.today
        end
        it 'removes date_managed' do
          expect(organization.date_managed).to eq(Date.today)
          expect { organization.record_date_managed }.to change { organization.date_managed }.from(Date.today).to(nil)
        end
      end
      context 'collection does not have a date_managed' do
        it 'does not change date_managed' do
          expect(organization.date_managed).to be_nil
          expect { organization.record_date_managed }.not_to change { organization.date_managed }
        end
      end
    end
    context 'collection has managers' do
      before do
        organization.managers << user
        organization.managers_group.save!
      end
      context 'collection has a date_managed' do
        before do
          organization.date_managed = Date.today
        end
        it 'does not change the date_managed' do
          expect(organization.date_managed).to eq(Date.today)
          expect { organization.record_date_managed }.not_to change { organization.date_managed }
        end
      end
      context 'collections does not have a date_managed' do
        before do
          organization.date_managed = nil
        end

        it 'adds a date_managed' do
          expect(organization.date_managed).to be_nil
          expect { organization.record_date_managed }.to change { organization.date_managed }.from(nil).to(Date.today)
        end
      end
    end

    context 'collection has only an admin manager' do
      let(:admin) { FactoryBot.create(:admin) }

      before do
        organization.managers_group.users = [admin]
        organization.managers_group.save!
      end

      context 'collection has a date_managed' do
        before do
          organization.date_managed = Date.today
        end

        it 'removes date_managed' do
          expect { organization.record_date_managed }.to change { organization.date_managed }.from(Date.today).to(nil)
        end
      end

      context 'collection does not have a date_managed' do
        before do
          organization.date_managed = nil
        end

        it 'does not change date_managed' do
          expect { organization.record_date_managed }.not_to change { organization.date_managed }
        end
      end
    end
  end
end
