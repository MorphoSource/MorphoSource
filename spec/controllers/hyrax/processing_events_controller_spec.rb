# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe Hyrax::ProcessingEventsController do
  it "should have curation_concern_type ::ProcessingEvent" do
    expect(Hyrax::ProcessingEventsController.curation_concern_type).to be(::ProcessingEvent)
  end
   it "should have show_presenter Hyrax::ProcessingEventPresenter" do
    expect(Hyrax::ProcessingEventsController.show_presenter).to be(Hyrax::ProcessingEventPresenter)
  end
end
