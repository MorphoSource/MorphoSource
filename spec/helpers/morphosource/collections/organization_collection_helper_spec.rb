require 'rails_helper'

RSpec.describe Morphosource::Collections::OrganizationCollectionHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe 'device_modalities' do
    let(:modality1_value) { Morphosource::ModalitiesService.new.option_values.sort[0] }
    let(:modality1_label) { Morphosource::ModalitiesService.new.label(modality1_value) }
    let(:modality2_value) { Morphosource::ModalitiesService.new.option_values.sort[1] }
    let(:modality2_label) { Morphosource::ModalitiesService.new.label(modality2_value) }
    let(:modalities)      { [modality1_value, modality2_value] }

    it 'returns a list of modality labels' do
      expect(helper.device_modalities(modalities)).to eq("#{modality1_label}</br>#{modality2_label}")
    end
  end

  describe 'total_viewable_device_media' do
    let(:user)          { FactoryBot.create(:registered_user)}
    let(:specimen)      { FactoryBot.create(:biological_specimen) }
    let(:device)        { FactoryBot.create(:device) }
    let(:imaging_event) { FactoryBot.create(:imaging_event, device_id: [device.id], ie_modality: [device.modality.first], physical_object_id: [specimen.id]) }
    let(:media)         { FactoryBot.create(:public_media) }

    subject { Morphosource::Collections::OrganizationCollections::DevicesController.new }

    before do
      imaging_event.ordered_members << media
      imaging_event.save!
      media.update_index
      allow(subject).to receive(:current_ability).and_return(Ability.new(user))
    end

    it 'returns the correct counts of media and imaging events' do
      expect(subject.device_media_and_imaging_event_counts(device.id)).to match_array([1, 1])
    end
  end
end