require 'rails_helper'

RSpec.describe Morphosource::Users::AccountMergerService do

  let!(:old_user)  { User.create(email: 'old@email.com', password: 'password') }
  let!(:new_user)  { User.create(email: 'new@email.com', password: 'password') }

  subject { described_class.call(old_user.email, new_user.email) }

  describe '.call' do
    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
    end
  end

  describe '#call' do
    it 'calls the transfer methods' do
      expect_any_instance_of(described_class).to receive(:transfer_works)
      expect_any_instance_of(described_class).to receive(:transfer_collections)
      expect_any_instance_of(described_class).to receive(:transfer_group_permissions)
      expect_any_instance_of(described_class).to receive(:transfer_proxy_rights)
      subject
    end
  end

  describe '#transfer_works' do
    describe 'Hyrax.config.index_related_works' do
      it 'sets index_related_works to false' do
        subject
        expect(Hyrax.config.index_related_works).to eq(false)
      end
    end

    describe 'calling work transfer methods' do
      let(:work)  { Media.new(title: ['media']) }
      let(:works) { [work] }

      before do
        allow_any_instance_of(described_class).to receive(:works).and_return(works)
      end

      it 'calls work transfer methods' do
        expect_any_instance_of(described_class).to receive(:transfer_roles).with(work)
        expect_any_instance_of(described_class).to receive(:transfer_individual_access).with(work)
        expect(work).to receive(:save!)
        expect_any_instance_of(described_class).to receive(:transfer_fileset_access).with(work)
        subject
      end
    end
  end

  describe 'transfering works and file sets' do
    # deposited works
    let!(:media1)           { Media.create(title: ['media1'], depositor: old_user.ms_id) }
    let!(:file_set1)        { FileSet.create(depositor: old_user.ms_id) }
    let!(:media2)           { Media.create(title: ['media2'], depositor: old_user.ms_id) }
    let!(:file_set2)        { FileSet.create(depositor: old_user.ms_id) }
    let!(:specimen)         { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'], depositor: old_user.ms_id) }
    let!(:cho)              { CulturalHeritageObject.create(title: ['cho'], vouchered: ['No'], depositor: old_user.ms_id) }
    let!(:device)           { FactoryBot.valkyrie_create(:device_resource, title: ['device'], depositor: old_user.ms_id, modality: ['Photogrammetry']) }
    let!(:imaging_event)    { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], ie_modality: device.modality, depositor: old_user.ms_id) }
    let!(:processing_event) { ProcessingEvent.create(title: ['processing event'], depositor: old_user.ms_id) }
    let!(:organization)     { Organization.create(title: ['specimen'], depositor: old_user.ms_id) }

    # shared_works
    let!(:media3)           { Media.create(title: ['media3']) }
    let!(:file_set3)        { FileSet.create() }
    let!(:media4)           { Media.create(title: ['media4']) }
    let!(:file_set4)        { FileSet.create() }
    let!(:media5)           { Media.create(title: ['media5']) }
    let!(:file_set5)        { FileSet.create() }

    let(:media)             { [media1, media2, media3, media4, media5] }
    let(:works)             { [media1, media2, media3, media4, media5, file_set1, file_set2, file_set3, file_set4, file_set5, specimen, cho, imaging_event, processing_event, organization, device] }

    before do
      media3.read_users += [old_user]
      media4.edit_users += [old_user]
      media5.download_users += [old_user]
      media1.ordered_members << file_set1
      media2.ordered_members << file_set2
      media3.ordered_members << file_set3
      media4.ordered_members << file_set4
      media5.ordered_members << file_set5
      [media1, media2, media3, media4, media5].each(&:save!)
      media.each { |m| InheritPermissionsJob.perform_now(m.id) }
      subject
      works.each do |work|
        if work.respond_to?(:reload)
          work.reload
        else
          work = Hyrax.query_service.find_by(id: work.id.to_s)
        end
      end
    end

    describe 'transfer_works' do
      it 'transfers all works and file sets to the new user' do
        # transfer depositor
        expect(media1.depositor).to eq(new_user.ms_id)
        expect(file_set1.depositor).to eq(new_user.ms_id)
        expect(media2.depositor).to eq(new_user.ms_id)
        expect(file_set2.depositor).to eq(new_user.ms_id)
        expect(specimen.depositor).to eq(new_user.ms_id)
        expect(cho.depositor).to eq(new_user.ms_id)
        expect(imaging_event.depositor).to eq(new_user.ms_id)
        expect(processing_event.depositor).to eq(new_user.ms_id)
        expect(organization.depositor).to eq(new_user.ms_id)
        if device.is_a?(Valkyrie::Resource)
          expect(device.depositor).to eq(old_user.ms_id)
        else
          expect(device.depositor).to eq(new_user.ms_id)
        end
        # transfer work/file_set user permissions
        expect(media3.read_users).to include(new_user.ms_id)
        expect(file_set3.read_users).to include(new_user.ms_id)
        expect(media4.edit_users).to include(new_user.ms_id)
        expect(file_set4.edit_users).to include(new_user.ms_id)
        expect(media5.download_users).to include(new_user.ms_id)
        expect(file_set5.download_users).to include(new_user.ms_id)
      end
    end
  end

  describe 'transfer_collections' do
    let!(:deposited_team)           { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.to_global_id, depositor: old_user.ms_id) }
    let!(:deposited_project)        { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.to_global_id, depositor: old_user.ms_id) }

    let(:collections)               { [deposited_team, deposited_project] }

    before do
      subject
      collections.each(&:reload)
    end

    it 'updates the collection depositor' do
      expect(deposited_team.depositor).to eq(new_user.ms_id)
      expect(deposited_project.depositor).to eq(new_user.ms_id)
    end
  end

  describe 'transfer_group_permissions' do
    let!(:role1)  { Role.create(name: 'role1') }
    let!(:role2)  { Role.create(name: 'role2') }
    let!(:role3)  { Role.create(name: 'role3') }

    let(:groups)  { [role1, role2, role3] }

    before do
      groups.each do |group|
        group.users += [old_user]
        group.save
      end
      old_user.reload
      subject
      old_user.reload
      new_user.reload
    end

    it 'transfers role memberships to the new user' do
      expect(old_user.groups).not_to include('role1','role2','role3')
      expect(new_user.groups).to include('role1','role2','role3')
    end
  end

  describe 'transfer_proxy_rights' do
    let(:another_user)    { User.create(email: 'another@email.com', password: 'password') }
    let!(:grantor_proxy)  { ProxyDepositRights.create(grantor_id: old_user.id, grantee_id: another_user.id) }
    let!(:grantee_proxy)  { ProxyDepositRights.create(grantor_id: another_user.id, grantee_id: old_user.id) }

    before do
      subject
      [grantor_proxy, grantee_proxy].each(&:reload)
    end

    it 'transfers proxy rights to the new user' do
      expect(grantor_proxy.grantor_id).to eq(new_user.id)
      expect(grantee_proxy.grantee_id).to eq(new_user.id)
    end
  end

  describe 'transfer_roles' do
    let(:work)  { Media.new(title: ['work'], depositor: old_user.ms_id, owner: old_user.ms_id, download_reviewer: [old_user.ms_id], proxy_depositor: old_user.ms_id, on_behalf_of: old_user.ms_id) }
    let(:works) { [work] }

    before do
      allow_any_instance_of(described_class).to receive(:works).and_return(works)
      subject
    end

    it 'assigns the new user to old user roles' do
      expect(work.depositor).to eq(new_user.ms_id)
      expect(work.owner).to eq(new_user.ms_id)
      expect(work.download_reviewer).to include(new_user.ms_id)
      expect(work.proxy_depositor).to eq(new_user.ms_id)
      expect(work.on_behalf_of).to eq(new_user.ms_id)
    end
  end

  describe 'transfer_cart_items' do
    let(:cart_item) { CartItem.create(user_id: old_user.ms_id, work_id: 'media_id', action_by: old_user.ms_id) }

    before do
      allow_any_instance_of(described_class).to receive(:cart_items).and_return([cart_item])
      subject
    end

    it 'associates the cart item with the new user' do
      expect(cart_item.user_id).to eq(new_user.ms_id)
      expect(cart_item.action_by).to eq(new_user.ms_id)
    end
  end

  describe 'works' do
    # user roles
    let!(:deposited_work)       { Media.create(title: ['deposited work'], depositor: old_user.ms_id) }
    let!(:owned_work)           { Media.create(title: ['owned work'], owner: old_user.ms_id) }
    let!(:reviewed_work)        { Media.create(title: ['reviewed work'], download_reviewer: [old_user.ms_id]) }
    let!(:proxy_deposited_work) { Media.create(title: ['proxy deposted work'], proxy_depositor: old_user.ms_id) }
    let!(:on_behalf_of_work)    { Media.create(title: ['on behalf of work'], on_behalf_of: old_user.ms_id) }
    # user permissions
    let!(:edit_access_work)     { Media.create(title: ['edit access work']) }
    let!(:download_access_work) { Media.create(title: ['download access work']) }
    let!(:read_access_work)     { Media.create(title: ['read access work']) }
    # unassociated work
    let!(:another_work)         { Media.create(title: ['another work'], depositor: new_user.ms_id) }

    subject { described_class.new(old_user.email, new_user.email) }

    let(:user_works)  { [deposited_work, owned_work, reviewed_work, proxy_deposited_work, on_behalf_of_work, edit_access_work, download_access_work, read_access_work] }

    before do
      edit_access_work.edit_users += [old_user]
      download_access_work.download_users += [old_user]
      read_access_work.read_users += [old_user]
      [edit_access_work, download_access_work, read_access_work].each(&:save!)
    end

    it 'returns all works associated with the old user' do
      expect(subject.works).to match_array(user_works)
    end
  end

  describe 'collections' do
    let!(:deposited_team)           { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.to_global_id, depositor: old_user.ms_id) }
    let!(:deposited_project)        { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.to_global_id, depositor: old_user.ms_id) }
    let!(:another_project)          { Collection.create(title: ['Another Project'], collection_type_gid: project_collection_type.to_global_id) }

    subject { described_class.new(old_user.email, new_user.email) }

    it 'returns all collections deposited by the old user' do
      expect(subject.collections).to include(deposited_project)
      expect(subject.collections).to include(deposited_team)
      expect(subject.works).not_to include(another_project)
    end
  end

  describe 'proxy_rights' do
    let!(:grantor_proxy)  { ProxyDepositRights.create(grantor_id: old_user.id, grantee_id: new_user.id) }
    let!(:grantee_proxy)  { ProxyDepositRights.create(grantor_id: new_user.id, grantee_id: old_user.id) }
    let!(:another_proxy)  { ProxyDepositRights.create(grantor_id: new_user.id, grantee_id: new_user.id) }

    subject { described_class.new(old_user.email, new_user.email) }

    it 'returns all proxy rights where the old user is a grantor or grantee' do
      expect(subject.proxy_rights).to include(grantor_proxy)
      expect(subject.proxy_rights).to include(grantee_proxy)
      expect(subject.proxy_rights).not_to include(another_proxy)
    end
  end

  describe 'cart_items' do
    let(:another_user)  { User.create(email: 'another@email.com', password: 'password') }
    let(:media)         { Media.create(title: ['media']) }
    let(:owned_item)    { CartItem.create(user_id: old_user.ms_id, work_id: media.id) }
    let(:acted_on_item) { CartItem.create(user_id: another_user.ms_id, work_id: media.id, action_by: old_user.ms_id) }
    let(:another_item)  { CartItem.create(user_id: another_user.ms_id, work_id: media.id) }

    let(:old_user_items){ [owned_item, acted_on_item] }

    subject { described_class.new(old_user.email, new_user.email) }

    it 'returns all cart items associated with the user' do
      expect(subject.cart_items).to match_array(old_user_items)
    end
  end
end
