require 'rails_helper'

# Tests transferring media to organizations through the submissions controller

RSpec.describe SubmissionsController, type: :controller do
  let(:data_manager)        { FactoryBot.create(:contributor) }
  let(:depositor)           { FactoryBot.create(:contributor) }
  let(:submission)          { Submission.new( { form_data: {}, work_data: {} } ) }
  let(:specimen)            { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
  let(:device)              { FactoryBot.create(:device_resource, modality: ['Photogrammetry']) }
  let!(:imaging_event)      { FactoryBot.create(:imaging_event, device_id: [device.id.to_s], ie_modality: device.modality, physical_object_id: [specimen.id]) }
  let(:media)               { Media.last }
  let(:visibility)          { '' }
  let(:transfer_management) { '' }
  let(:params)              { ActionController::Parameters.new( { "media" => {
                                                                    "media_type" => "Image",
                                                                    "visibility" => visibility,
                                                                    "transfer_management" => transfer_management
                                                                  } } ) }

  before do
    submission.instance_variable_set(:@organization_id, organization.id)
    submission.imaging_event_id = imaging_event.id
    submission.raw_or_derived_media = 'raw'
    allow(subject).to receive(:params).and_return(params)
    subject.instance_variable_set(:@submission, submission)
    allow(::ActiveFedora::Base).to receive(:find).and_call_original
    allow(::ActiveFedora::Base).to receive(:find).with(imaging_event.id).and_return(imaging_event)
    sign_in depositor
  end

  describe 'create_work_if_needed' do

    context 'organization is an organization collection' do
      before do
        organization.managers << data_manager
        organization.managers_group.save
        subject.send(:create_work_if_needed, 'media', params)
      end

      context 'media_ownership_transfer is nil' do
        let(:organization)  { FactoryBot.create(:organization_collection, depositor: data_manager.ms_id) }

        context 'visibility is restricted' do
          let(:visibility)  { 'restricted' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
        end
        context 'visibility is open' do
          let(:visibility)  { 'open' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
        end
      end
      context 'media_ownership_transfer is false' do
        let(:organization)  { FactoryBot.create(:organization_collection, depositor: data_manager.ms_id, media_ownership_transfer: false) }
        context 'visibility is restricted' do
          let(:visibility)  { 'restricted' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
        end
        context 'visibility is open' do
          let(:visibility)  { 'open' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'does not transfer' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
        end
      end
      context 'media_ownership_transfer is true' do
        let(:organization)  { FactoryBot.create(:organization_collection, id: 'test', depositor: data_manager.ms_id, media_ownership_transfer: true) }

        before do
          organization.managers << data_manager
          organization.managers_group.save
        end

        context 'visibility is restricted' do
          let(:visibility)  { 'restricted' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'transfers immediately' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(1)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'marks the media for transfer later' do
              expect(media.organization_transfer_on_publish).to eq(true)
              expect(ProxyDepositRequest.count).to eq(0)
            end
          end
        end
        context 'visibility is open' do
          let(:visibility)  { 'open' }
          context 'depositor chooses transfer immediately' do
            let(:transfer_management) { 'immediate' }
            it 'transfers immediately' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(1)
            end
          end
          context 'depositor chooses transfer on publication' do
            let(:transfer_management) { 'publication' }
            it 'transfers immediately' do
              expect(media.organization_transfer_on_publish).to eq(nil)
              expect(ProxyDepositRequest.count).to eq(1)
            end
          end
        end
      end
    end
  end
end
