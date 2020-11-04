# Generated via
#  `rails generate hyrax:work Organization`
require 'rails_helper'

RSpec.describe Hyrax::OrganizationsController do
  it "should have curation_concern_type ::Organization" do
    expect(Hyrax::OrganizationsController.curation_concern_type).to be(::Organization)
  end

  it "should have show_presenter Hyrax::WorkShowPresenter" do
  	expect(Hyrax::OrganizationsController.show_presenter).to be(Hyrax::WorkShowPresenter)
  end
end
