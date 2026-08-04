# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ImagingEventsController do
  describe 'instance methods' do
    let(:device)         { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
    let(:specimen)       { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes']) }
    let(:imaging_event)  { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }
    let(:user)           { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

    before do
      allow(subject).to receive(:authorize!).with(:destroy, imaging_event).and_return(true)
      sign_in user
    end

    describe '#destroy' do
      context 'when the destroy is not halted' do
        it 'destroys the imaging event' do
          delete :destroy, params: { id: imaging_event.id }
          expect(ImagingEvent.exists?(imaging_event.id)).to be false
        end
      end

      context 'when the destroy is halted and populates errors' do
        before do
          allow_any_instance_of(ImagingEvent).to receive(:destroy) do |record|
            record.errors.add(:base, 'boom')
            false
          end
        end

        it 'does not destroy the imaging event and redirects with the error instead of a silent 204' do
          delete :destroy, params: { id: imaging_event.id }
          expect(response).to have_http_status(:found)
          expect(flash[:alert]).to eq('boom')
          # .exists? is Solr-backed; CleanupFileSetsActor deletes the Solr doc before
          # the model-level destroy runs, so .find (reads Fedora directly) is what
          # actually proves the record survived.
          expect { ImagingEvent.find(imaging_event.id) }.not_to raise_error
        end

        it 'renders an unprocessable_entity json response' do
          delete :destroy, params: { id: imaging_event.id, format: :json }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the destroy is halted without populating errors' do
        before do
          allow_any_instance_of(ImagingEvent).to receive(:destroy).and_return(false)
        end

        it 'falls back to a generic unable-to-delete message' do
          delete :destroy, params: { id: imaging_event.id }
          expect(flash[:alert]).to match(/\AUnable to delete .*imaging event\.\z/)
        end
      end
    end
  end
end
