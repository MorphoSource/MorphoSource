# Generated via
#  `rails generate hyrax:work Device`
require 'rails_helper'

RSpec.describe Hyrax::DevicesController do
  it "should have curation_concern_type ::Device" do
    expect(Hyrax::DevicesController.curation_concern_type).to be(::Device)
  end
   it "should have show_presenter Hyrax::DevicePresenter" do
  	expect(Hyrax::DevicesController.show_presenter).to be(Hyrax::DevicePresenter)
  end
end
