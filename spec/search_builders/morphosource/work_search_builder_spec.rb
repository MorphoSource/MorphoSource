require 'rails_helper'

RSpec.describe Morphosource::WorkSearchBuilder do
  let(:params) do
    {"locale"=>"en", "controller"=>"hyrax/media", "id"=>"test_id"}
  end

  let(:builder) { described_class.new(params: params) }

  describe '#discovery_permissions' do
    subject { builder.discovery_permissions }

    it { is_expected.to eq %w[edit discover download read] }
  end
end
