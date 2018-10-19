# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Media do
  subject { described_class.new }

  it_behaves_like 'a Morphosource work'

  it "is valid with valid attributes" do
      subject.title = ["foo"]
      subject.modality = ["foo"]
      subject.media_type = ["foo"]
      subject.side = nil
      subject.part = nil
      subject.orientation = nil
      subject.funding = nil
      subject.cite_as = nil
      subject.rights_holder = ["foo"]
      subject.agreement_uri = ["foo"]
      subject.legacy_media_file_id = ["123"]
      subject.uuid = ["foo"]
      subject.ark = ["foo"]
      subject.doi = ["foo"]
      subject.available = ["foo"]
      subject.number_of_images_in_set = 33
      subject.x_spacing = ["foo"]
      subject.y_spacing = ["foo"]
      subject.z_spacing = ["foo"]
      subject.scale_bar = ["foo"]
      subject.unit = ["foo"]
      subject.map_type = ["foo"]
      expect(subject).to be_valid
  end

  it "is not valid without required fields - title, modality, media_type" do
      subject.title = nil
      subject.modality = nil
      subject.media_type = nil
      subject.side = ["foo"]
      subject.part = nil
      subject.orientation = nil
      subject.funding = nil
      subject.cite_as = nil
      subject.rights_holder = ["foo"]
      subject.agreement_uri = ["foo"]
      subject.legacy_media_file_id = ["123"]
      subject.uuid = ["foo"]
      subject.ark = ["foo"]
      subject.doi = ["foo"]
      subject.available = ["foo"]
      subject.number_of_images_in_set = 33
      subject.x_spacing = ["foo"]
      subject.y_spacing = ["foo"]
      subject.z_spacing = ["foo"]
      subject.scale_bar = ["foo"]
      subject.unit = ["foo"]
      subject.map_type = ["foo"]
      expect(subject).to_not be_valid
  end


end
