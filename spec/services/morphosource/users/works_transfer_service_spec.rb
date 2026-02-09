require 'rails_helper'

RSpec.describe Morphosource::Users::WorksTransferService do

  let!(:old_user)       { User.create(email: 'old@email.com', password: 'password') }
  let!(:new_user)       { User.create(email: 'new@email.com', password: 'password') }
  let(:another_user)    { User.create(email: 'another@email.com', password: 'password') }

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

    let(:media)             { [media1, media2] }
    let(:works)             { [media1, media2, file_set1, file_set2, specimen, cho, imaging_event, processing_event, organization, device] }

    before do
      media1.edit_users += [media1.depositor]
      media2.edit_users += [media2.depositor]
      media1.ordered_members << file_set1
      media2.ordered_members << file_set2
      [media1, media2].each(&:save!)
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
        # transfer owner
        expect(media1.depositor).to eq(old_user.ms_id)
        expect(media1.owner).to eq(new_user.ms_id)
        expect(file_set1.depositor).to eq(old_user.ms_id)
        expect(file_set1.edit_users).to include(new_user.ms_id)

        expect(media2.depositor).to eq(old_user.ms_id)
        expect(media2.owner).to eq(new_user.ms_id)
        expect(file_set2.depositor).to eq(old_user.ms_id)
        expect(file_set2.edit_users).to include(new_user.ms_id)

        expect(specimen.depositor).to eq(old_user.ms_id)
        expect(specimen.owner).to eq(new_user.ms_id)

        expect(cho.depositor).to eq(old_user.ms_id)
        expect(cho.owner).to eq(new_user.ms_id)

        expect(imaging_event.depositor).to eq(old_user.ms_id)
        expect(imaging_event.owner).to eq(new_user.ms_id)

        expect(processing_event.depositor).to eq(old_user.ms_id)
        expect(processing_event.owner).to eq(new_user.ms_id)

        expect(organization.depositor).to eq(old_user.ms_id)
        expect(organization.owner).to eq(new_user.ms_id)

        expect(device.depositor).to eq(old_user.ms_id)
        if device.respond_to?(:owner)
          expect(device.owner).to eq(new_user.ms_id)
        end
      end
    end
  end

  describe 'transfer_roles' do
    let(:deposited_work)            { Media.new(title: ['work'], depositor: old_user.ms_id) }
    let(:owned_work)                { Media.new(title: ['work'], depositor: another_user.ms_id, owner: old_user.ms_id) }
    let(:reviewed_work)             { Media.new(title: ['work'], depositor: another_user.ms_id, download_reviewer: [old_user.ms_id]) }
    let(:deposited_not_owned_work)  { Media.new(title: ['work'], depositor: old_user.ms_id, owner: another_user.ms_id) }
    let(:works)                     { [deposited_work, owned_work, reviewed_work, deposited_not_owned_work] }

    before do
      allow_any_instance_of(described_class).to receive(:works).and_return(works)
      subject
    end

    it 'assigns the new user to old user roles' do
      expect(deposited_work.owner).to eq(new_user.ms_id)
      expect(owned_work.owner).to eq(new_user.ms_id)
      expect(reviewed_work.download_reviewer).to match_array(new_user.ms_id)
      expect(deposited_not_owned_work.owner).to eq(another_user.ms_id)
    end
  end

  describe 'works' do
    # user roles
    let!(:deposited_work)       { Media.create(title: ['deposited work'], depositor: old_user.ms_id) }
    let!(:owned_work)           { Media.create(title: ['owned work'], owner: old_user.ms_id) }
    let!(:reviewed_work)        { Media.create(title: ['reviewed work'], download_reviewer: [old_user.ms_id]) }
    # unassociated work
    let!(:another_work)         { Media.create(title: ['another work'], depositor: new_user.ms_id) }

    subject { described_class.new(old_user.email, new_user.email) }

    let(:user_works)  { [deposited_work, owned_work, reviewed_work] }

    it 'returns all works associated with the old user' do
      expect(subject.works).to match_array(user_works)
    end
  end

end
