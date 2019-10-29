require 'rails_helper'

include ActionDispatch::TestProcess

RSpec.describe RegistrationsController, :type => :controller  do

  let(:params) { {user: {email: "user@test.com", password: 'password', display_name: "Test User", affiliation: "Test Affiliation", department: "Test Department", address: "Test Address", country: "US", state: "NC", postal_code: "27278", telephone: "5555555555", demographics: ["demo1", "demo2", ""], intent: ["intent1", "intent2", ""], software: ["software1", "software2", ""], mesh_file_type: ["type1", "type2", ""], volume_file_type: ["type3", "type4", ""], printer_model: ["model1", "model2", ""], printer_file: ["type5", "type6", ""], orcid: "https://orcid.org/0000-0000-0000-0000", twitter_handle: "@TestTest", facebook_handle: "test.test", website: "morphosource.org", terms_read: true }}}

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'creates a new user with morphosource attributes, and removes empty strings from multi-value fields' do
    expect{
      process :create, method: :post, params: params
    }.to change{User.count}.by(1)
    user = User.last
    expect(user.email).to eq("user@test.com")
    expect(user.facebook_handle).to eq("test.test")
    expect(user.twitter_handle).to eq("@TestTest")
    expect(user.display_name).to eq("Test User")
    expect(user.address).to eq("Test Address")
    expect(user.department).to eq("Test Department")
    expect(user.website).to eq("morphosource.org")
    expect(user.affiliation).to eq("Test Affiliation")
    expect(user.telephone).to eq("5555555555")
    expect(user.orcid).to eq("https://orcid.org/0000-0000-0000-0000")
    expect(user.state).to eq("NC")
    expect(user.country).to eq("US")
    expect(user.postal_code).to eq("27278")
    expect(user.terms_read).to eq(true)
    expect(user.demographics).to match_array(["demo1", "demo2"])
    expect(user.intent).to match_array(["intent1", "intent2"])
    expect(user.software).to match_array(["software1", "software2"])
    expect(user.mesh_file_type).to match_array(["type1", "type2"])
    expect(user.volume_file_type).to match_array(["type3", "type4"])
    expect(user.printer_model).to match_array(["model1", "model2"])
    expect(user.printer_file).to match_array(["type5", "type6"])
  end
end
