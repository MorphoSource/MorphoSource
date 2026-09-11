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

  describe 'download reviewer metadata' do
    let(:reviewer)       { FactoryBot.create(:contributor) }
    let(:other_reviewer) { FactoryBot.create(:contributor) }
    let(:manager)        { FactoryBot.create(:contributor) }
    let!(:organization)  { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

    describe '#managers_are_download_reviewers' do
      it 'reads a never-written field as manager mode' do
        expect(organization.managers_are_download_reviewers).to be(true)
      end

      it 'leaves a brand-new organization valid with the field never written' do
        expect(organization).to be_valid
      end

      it 'reads a written false as custom mode' do
        organization.managers_are_download_reviewers = false

        expect(organization.managers_are_download_reviewers).to be(false)
      end

      it 'round-trips through a save' do
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!

        expect(organization.reload.managers_are_download_reviewers).to be(false)
      end
    end

    describe 'boolean casting on assignment' do
      it 'casts the string "false" to false' do
        organization.managers_are_download_reviewers = 'false'

        expect(organization.managers_are_download_reviewers).to be(false)
      end

      it 'casts the string "true" to true' do
        organization.managers_are_download_reviewers = 'true'

        expect(organization.managers_are_download_reviewers).to be(true)
      end

      it 'casts an empty string to nil, leaving the reader in manager mode' do
        organization.managers_are_download_reviewers = ''

        expect(organization.managers_are_download_reviewers).to be(true)
      end

      it 'casts reviews_object_media_downloads too' do
        organization.reviews_object_media_downloads = 'false'

        expect(organization.reviews_object_media_downloads).to be(false)
      end

      it 'leaves a never-assigned field unchanged' do
        expect(organization.managers_are_download_reviewers_changed?).to be(false)
      end
    end

    describe '#custom_download_reviewer_users' do
      it 'stores multiple ms_ids' do
        organization.custom_download_reviewer_users = [reviewer.ms_id, other_reviewer.ms_id]
        organization.save!

        expect(organization.reload.custom_download_reviewer_users)
          .to match_array([reviewer.ms_id, other_reviewer.ms_id])
      end
    end

    describe '#reviews_object_media_downloads' do
      it 'stores a boolean' do
        organization.reviews_object_media_downloads = true
        organization.save!

        expect(organization.reload.reviews_object_media_downloads).to be(true)
      end
    end

    describe '#download_reviewer' do
      it 'is still the stored property' do
        organization.download_reviewer = [reviewer.ms_id]
        organization.save!

        expect(organization.reload.download_reviewer).to eq([reviewer.ms_id])
      end
    end

    describe '#download_reviewers' do
      def add_manager(u)
        organization.managers << u
        organization.managers_group.save!
      end

      context 'manager mode with a blank custom list' do
        before do
          add_manager(manager)
          organization.managers_are_download_reviewers = true
        end

        it 'returns the manager ms_ids' do
          expect(organization.download_reviewers).to eq([manager.ms_id])
        end
      end

      context 'manager mode with a populated custom list' do
        before do
          add_manager(manager)
          organization.managers_are_download_reviewers = true
          organization.custom_download_reviewer_users = [reviewer.ms_id]
        end

        it 'returns the manager ms_ids -- manager mode overrides custom' do
          expect(organization.download_reviewers).to eq([manager.ms_id])
        end
      end

      context 'custom mode with a populated custom list' do
        before do
          add_manager(manager)
          organization.managers_are_download_reviewers = false
          organization.custom_download_reviewer_users = [reviewer.ms_id, other_reviewer.ms_id]
        end

        it 'returns the custom user ms_ids and not the managers' do
          expect(organization.download_reviewers).to match_array([reviewer.ms_id, other_reviewer.ms_id])
        end
      end

      context 'custom mode naming a mix of live and dead ms_ids' do
        before do
          add_manager(manager)
          organization.managers_are_download_reviewers = false
          organization.custom_download_reviewer_users = ['dead-ms-id', reviewer.ms_id]
        end

        it 'drops the ms_ids with no User row' do
          expect(organization.download_reviewers).to eq([reviewer.ms_id])
        end
      end

      context 'custom mode whose ms_ids are all dead' do
        before do
          add_manager(manager)
          organization.managers_are_download_reviewers = false
          organization.custom_download_reviewer_users = ['dead-ms-id', 'also-dead']
        end

        it 'falls back to the managers, as media_download_reviewers does' do
          expect(organization.download_reviewers).to eq([manager.ms_id])
        end
      end

      context 'custom mode whose ms_ids are all dead, with no managers' do
        before do
          organization.managers_are_download_reviewers = false
          organization.custom_download_reviewer_users = ['dead-ms-id']
        end

        it 'returns an empty array' do
          expect(organization.download_reviewers).to eq([])
        end
      end

      context 'manager mode with no managers' do
        it 'returns an empty array' do
          expect(organization.download_reviewers).to eq([])
        end
      end

      context 'reviews_object_media_downloads' do
        before { add_manager(manager) }

        it 'is ignored when true' do
          organization.reviews_object_media_downloads = true

          expect(organization.download_reviewers).to eq([manager.ms_id])
        end

        it 'is ignored when false' do
          organization.reviews_object_media_downloads = false

          expect(organization.download_reviewers).to eq([manager.ms_id])
        end
      end

      it 'never returns an org_collection: token' do
        add_manager(manager)

        expect(organization.download_reviewers).to all(satisfy { |v| !v.to_s.start_with?('org_collection:') })
      end

      it 'has no setter' do
        expect(organization).not_to respond_to(:download_reviewers=)
      end
    end

    describe 'custom mode with no live reviewers' do
      before do
        add_manager(manager)
        organization.managers_are_download_reviewers = false
      end

      def add_manager(u)
        organization.managers << u
        organization.managers_group.save!
      end

      it 'is valid with a list whose ms_ids are all dead' do
        organization.custom_download_reviewer_users = ['dead-ms-id']

        expect(organization).to be_valid
      end

      it 'is valid with an empty list' do
        organization.custom_download_reviewer_users = []

        expect(organization).to be_valid
      end

      it 'saves, and resolves to the managers' do
        organization.custom_download_reviewer_users = ['dead-ms-id']
        organization.save!

        expect(organization.reload.download_reviewers).to eq([manager.ms_id])
      end
    end

    describe '#publish_reviewers_updated' do
      it 'publishes when the mode changes' do
        expect(Hyrax.publisher)
          .to receive(:publish).with('organization.reviewers.updated', organization_id: organization.id)

        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!
      end

      it 'publishes when the custom user list changes in custom mode' do
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!

        expect(Hyrax.publisher)
          .to receive(:publish).with('organization.reviewers.updated', organization_id: organization.id)

        organization.custom_download_reviewer_users = [reviewer.ms_id, other_reviewer.ms_id]
        organization.save!
      end

      it 'publishes nothing when the custom user list changes in manager mode' do
        expect(Hyrax.publisher).not_to receive(:publish).with('organization.reviewers.updated', any_args)

        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!
      end

      it 'publishes nothing for an unrelated save' do
        expect(Hyrax.publisher).not_to receive(:publish).with('organization.reviewers.updated', any_args)

        organization.city = ['Durham']
        organization.save!
      end

      it 'is suppressed by skip_reviewer_event' do
        expect(Hyrax.publisher).not_to receive(:publish).with('organization.reviewers.updated', any_args)

        organization.skip_reviewer_event = true
        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!
      end

      it 'does not fail the save when the publish itself raises' do
        allow(Hyrax.publisher).to receive(:publish)
          .with('organization.reviewers.updated', any_args).and_raise(Redis::CannotConnectError)

        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]

        expect { organization.save! }.not_to raise_error
      end

      it 'reports a failed publish to Sentry' do
        allow(Sentry).to receive(:capture_exception)
        allow(Hyrax.publisher).to receive(:publish)
          .with('organization.reviewers.updated', any_args).and_raise(Redis::CannotConnectError)

        organization.managers_are_download_reviewers = false
        organization.custom_download_reviewer_users = [reviewer.ms_id]
        organization.save!

        expect(Sentry).to have_received(:capture_exception)
          .with(instance_of(Redis::CannotConnectError), extra: { organization_id: organization.id })
      end
    end
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

    it 'creates the starter project without managers' do
      Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS)

      project = organization.send(:create_organization_project)
      expect(project.managers).to eq([])
      expect(organization.managers).to eq([])
      Collection::DEFAULT_GROUP_ROLES.each do |role|
        expect(Collection.role_group(project.id, role)).to be_present
      end
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

    # Organizations are created with no managers and no management date.
    it 'does not add the depositor as a manager' do
      expect(organization.managers).to eq([])
      expect(organization.date_managed).to be_nil
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
