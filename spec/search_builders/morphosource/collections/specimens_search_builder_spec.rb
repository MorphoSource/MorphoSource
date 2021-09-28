require 'rails_helper'

# frozen_string_literal: true
RSpec.describe Morphosource::Collections::SpecimensSearchBuilder do
  let(:user)      { User.create(email: 'registered@email.com', password: 'password') }
  let(:ability)   { ::Ability.new(user) }
  let(:scope)     { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability, params: {}) }

  subject { described_class.new(scope) }

  describe 'return_selected_fields' do
    let(:selected_fields) { 'id,has_model_ssim,title_tesim,taxonomy_tesim,date_uploaded_dtsi,record_source_ssim,idigbio_uuid_tesim' }

    it 'filters by the selected fields' do
      expect(subject.return_selected_fields({})).to eq(selected_fields)
    end
  end

  describe 'models' do
    it 'is BiologicalSpecimen' do
      expect(subject.models).to match_array([BiologicalSpecimen])
    end
  end
end
