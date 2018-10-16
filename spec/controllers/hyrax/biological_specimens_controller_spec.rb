# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimensController do
  it 'has curation_concern_type ::BiologicalSpecimen' do
    expect(described_class.curation_concern_type).to be(::BiologicalSpecimen)
  end

  it 'has show_presenter Hyrax::BiologicalSpecimenPresenter' do
    expect(described_class.show_presenter).to be(Hyrax::BiologicalSpecimenPresenter)
  end
end
