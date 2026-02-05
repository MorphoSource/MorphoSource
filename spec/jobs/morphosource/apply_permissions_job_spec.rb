require 'rails_helper'
RSpec.describe Morphosource::ApplyPermissionsJob do

  let(:depositor)        { FactoryBot.create(:contributor) }
  let(:open_media)       { FactoryBot.create(:media, fileset_accessibility: ['open'], fileset_visibility: ['open'], depositor: depositor.ms_id) }
  let(:restricted_media) { FactoryBot.create(:media, fileset_accessibility: ['restricted_download'], fileset_visibility: ['open'], visibility: nil, depositor: depositor.ms_id) }
  let(:private_media)    { FactoryBot.create(:media, fileset_accessibility: ['private'], fileset_visibility: ['restricted'], visibility: nil, depositor: depositor.ms_id) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  subject { described_class.perform_now(**params) }

  describe 'perform' do

    it 'calls permissions methods' do
      expect_any_instance_of(described_class).to receive(:update_permissions)
      described_class.perform_now(media_id: open_media.id, update_hierarchy: false)
    end

    context 'update_hierarchy is false' do
      let(:params)  { { media_id: media.id } }

      context 'media does not have permissions' do

        before do
          clear_permissions(media)
        end

        context 'media is open' do
          let(:media) { open_media }
          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload
            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to match_array(['public'])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq([])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin'])
          end
        end

        context 'media is restricted' do
          let(:media) { restricted_media }
          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload
            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to match_array(['public'])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq([])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin'])
          end
        end

        context 'media is private' do
          let(:media) { private_media }

          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload
            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to eq([])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq([])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin'])
          end
        end
      end

      context 'media has permissions' do
        let(:read_user)       { FactoryBot.create(:contributor) }
        let(:edit_user)       { FactoryBot.create(:contributor) }
        let(:download_user)   { FactoryBot.create(:contributor) }
        let(:read_group)      { Role.create(name: 'read_group' )}
        let(:edit_group)      { Role.create(name: 'edit_group' )}
        let(:download_group)  { Role.create(name: 'download_group' )}

        before do
          media.read_users = [read_user.ms_id]
          media.download_users = [download_user.ms_id]
          media.edit_users = [edit_user.ms_id]
          media.read_groups = [read_group.name]
          media.download_groups = [download_group.name]
          media.edit_groups = [edit_group.name]
          media.save!
        end

        context 'media is open' do
          let(:media) { open_media }

          it 'updates the permissions' do
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to eq([read_group.name])
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            expect(media.edit_users).to eq([edit_user.ms_id])
            expect(media.edit_groups).to eq([edit_group.name])
            subject
            open_media.reload
            # read
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to match_array(['public', read_group.name])
            # download
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            # edit
            expect(media.edit_users).to match_array([edit_user.ms_id, media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', edit_group.name])
          end
        end

        context 'media is restricted download' do
          let(:media) { restricted_media }

          it 'updates the permissions' do
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to eq([read_group.name])
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            expect(media.edit_users).to eq([edit_user.ms_id])
            expect(media.edit_groups).to eq([edit_group.name])
            subject
            open_media.reload
            # read
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to match_array(['public', read_group.name])
            # download
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            # edit
            expect(media.edit_users).to match_array([edit_user.ms_id, media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', edit_group.name])
          end
        end
        context 'media is private' do
          let(:media) { private_media }

          it 'updates the permissions' do
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to eq([read_group.name])
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            expect(media.edit_users).to eq([edit_user.ms_id])
            expect(media.edit_groups).to eq([edit_group.name])
            subject
            open_media.reload
            # read
            expect(media.read_users).to eq([read_user.ms_id])
            expect(media.read_groups).to match_array([read_group.name])
            # download
            expect(media.download_users).to match_array([download_user.ms_id])
            expect(media.download_groups).to eq([download_group.name])
            # edit
            expect(media.edit_users).to match_array([edit_user.ms_id, media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', edit_group.name])
          end
        end
      end

      context 'media belongs to a collection' do
        let(:project) { FactoryBot.create(:project, depositor: depositor.ms_id) }

        before do
          project.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
        end

        before do
          media.member_of_collections = [project]
          clear_permissions(media)
        end

        context 'media is open' do
          let(:media) { open_media }

          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload

            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to match_array(['public',"#{project.id}_viewers"])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq(["#{project.id}_downloaders"])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', "#{project.id}_editors", "#{project.id}_managers" ])
          end
        end

        context 'media is restricted download' do
          let(:media) { restricted_media }

          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload

            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to match_array(['public',"#{project.id}_viewers"])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq(["#{project.id}_downloaders"])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', "#{project.id}_editors", "#{project.id}_managers" ])
          end
        end

        context 'media is private' do
          let(:media) { private_media }

          it 'updates the permissions' do
            check_cleared_permissions(media)
            subject
            media.reload

            # read
            expect(media.read_users).to eq([])
            expect(media.read_groups).to match_array(["#{project.id}_viewers"])
            # download
            expect(media.download_users).to eq([])
            expect(media.download_groups).to eq(["#{project.id}_downloaders"])
            # edit
            expect(media.edit_users).to match_array([media.user_with_ownership])
            expect(media.edit_groups).to match_array(['admin', "#{project.id}_editors", "#{project.id}_managers" ])
          end
        end
      end
    end

    context 'update_hierarchy is true' do
      let(:params)  { { media_id: media.id, update_hierarchy: true } }

      context 'media has a broken hierarchy' do
        let!(:device)           { FactoryBot.create(:device_resource, id: '000000001', title: ['device'], modality: ['XRay']) }
        let!(:specimen)         { FactoryBot.create(:biological_specimen, id: '000000002') }
        let!(:imaging_event)    { FactoryBot.create(:imaging_event, id: '000000003', physical_object_id: [specimen.id], device_id: [device.id.to_s], ie_modality: device.modality) }
        let!(:processing_event) { FactoryBot.create(:processing_event, id: '000000004') }
        let!(:media)            { FactoryBot.create(:media, id: '000000005', visibility: 'open', fileset_visibility: ['open'], fileset_accessibility: ['open'], depositor: depositor.ms_id)}

        before do
          clear_permissions(media)
        end

        it 'repairs the Fedora relationships and updates permissions' do
          expect(media.physical_objects).to eq([])
          check_cleared_permissions(media)
          subject
          expect(media.physical_objects).to match_array([specimen])
          # read
          expect(media.read_users).to eq([])
          expect(media.read_groups).to match_array(['public'])
          # download
          expect(media.download_users).to eq([])
          expect(media.download_groups).to eq([])
          # edit
          expect(media.edit_users).to match_array([media.user_with_ownership])
          expect(media.edit_groups).to match_array(['admin'])
        end
      end
    end
  end

  def clear_permissions(media)
    visibility = nil
    media.read_users = []
    media.read_groups = []
    media.download_users = []
    media.download_groups = []
    media.edit_users = []
    media.edit_groups = []
    media.save!
  end

  def check_cleared_permissions(media)
    expect(media.read_users).to eq([])
    expect(media.read_groups).to eq([])
    expect(media.download_users).to eq([])
    expect(media.download_groups).to eq([])
    expect(media.edit_users).to eq([])
    expect(media.edit_groups).to eq([])
  end
end
