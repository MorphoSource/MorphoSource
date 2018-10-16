# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe Hyrax::CulturalHeritageObjectsController do
  it 'has curation_concern_type ::CulturalHeritageObject' do
    expect(described_class.curation_concern_type).to be(::CulturalHeritageObject)
  end

  it 'has show_presenter Hyrax::BiologicalSpecimenPresenter' do
    expect(described_class.show_presenter).to be(Hyrax::CulturalHeritageObjectPresenter)
  end
end
