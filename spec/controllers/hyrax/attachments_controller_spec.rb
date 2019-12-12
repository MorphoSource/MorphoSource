# Generated via
#  `rails generate hyrax:work Attachment`
require 'rails_helper'

RSpec.describe Hyrax::AttachmentsController do
  it "should have curation_concern_type ::Attachment" do
    expect(Hyrax::AttachmentsController.curation_concern_type).to be(::Attachment)
  end

   it "should have show_presenter Hyrax::AttachmentPresenter" do
  	expect(Hyrax::AttachmentsController.show_presenter).to be(Hyrax::AttachmentPresenter)
  end
end
