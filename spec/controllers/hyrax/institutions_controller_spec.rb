# Generated via
#  `rails generate hyrax:work Institution`
require 'rails_helper'

RSpec.describe Hyrax::InstitutionsController do
  it "should have curation_concern_type ::Institution" do
    expect(Hyrax::InstitutionsController.curation_concern_type).to be(::Institution)
  end

  it "should have show_presenter Hyrax::InstitutionPresenter" do
  	expect(Hyrax::InstitutionsController.show_presenter).to be(Hyrax::InstitutionPresenter)
  end
end
