require 'rails_helper'

RSpec.describe Morphosource::DataCuration::ApplyPermissionsService do

  include TestHelpers

  let(:media)   { FactoryBot.create(:media) }
  let(:params)  { { media_id: media.id } }

  subject { described_class.call(**params) }

  describe '.call' do
    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
    end
  end

  describe 'call' do
    context 'media_id is not present' do
      let(:params) { {} }
      it 'raises an error' do
        expect { subject }.to raise_error("Service requires media_id")
      end
    end
    context 'media_id is present' do
      it 'calls the ApplyPermissionsJob' do
        expect(Morphosource::ApplyPermissionsJob).to receive(:perform_later).with(media_id: media.id, update_hierarchy: false)
        subject
      end
    end
  end
end
