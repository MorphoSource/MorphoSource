require 'rails_helper'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::Dashboard::ProfilesController, :type => :controller  do

  let!(:user) { User.create(email: "user@test.com", display_name: "Test User", affiliation: "Test Affiliation", department: "Test Department", address: "Test Address", country: "US", state: "NC", postal_code: "27278", telephone: "5555555555", demographics: ["demo1", "demo2"], intent: ["intent1", "intent2"], software: ["software1", "software2"], mesh_file_type: ["type1", "type2"], volume_file_type: ["type3", "type4"], printer_model: ["model1", "model2"], printer_file: ["type5", "type6"], orcid: "https://orcid.org/0000-0000-0000-0000", twitter_handle: "@TestTest", facebook_handle: "test.test", website: "morphosource.org", terms_read: true, ms_id: "msid678") }

  let(:update_params) { {user: {display_name: "New Display Name", affiliation: "New Affiliation", department: "New Department", address: "New Address", country: "CA", state: "MB", postal_code: "New Code", telephone: "New Phone", demographics: ["newdemo1", "newdemo2", ""], intent: ["new intent1", "new intent2", ""], software: ["new software1", "new software2", ""], mesh_file_type: ["new type1", "new type2", ""], volume_file_type: ["new type3", "new type4", ""], printer_model: ["new model1", "new model2", ""], printer_file: ["new type5", "new type6", ""], orcid: "https://orcid.org/1111-1111-1111-1111", twitter_handle: "new twitter", facebook_handle: "new facebook", website: "new website", terms_read: true}, id: user.ms_id} }

  describe '#update' do

    before do
      sign_in user
      allow(User).to receive(:from_url_component).with(update_params[:id]).and_return(user)
      allow(User).to receive(:find).and_return(user)
    end

    it 'updates the user with MorphoSource attributes, and removes empty strings from multi-value attributes' do
      patch :update, params: update_params
      user.reload
      expect(user.display_name).to eq("New Display Name")
      expect(user.affiliation).to eq ("New Affiliation")
      expect(user.department).to eq("New Department")
      expect(user.address).to eq("New Address")
      expect(user.country).to eq("CA")
      expect(user.state).to eq("MB")
      expect(user.postal_code).to eq("New Code")
      expect(user.telephone).to eq("New Phone")
      expect(user.demographics).to match_array(["newdemo1", "newdemo2"])
      expect(user.intent).to match_array(["new intent1", "new intent2"])
      expect(user.software).to match_array(["new software1", "new software2"])
      expect(user.mesh_file_type).to match_array(["new type1", "new type2"])
      expect(user.volume_file_type).to match_array(["new type3", "new type4"])
      expect(user.printer_model).to match_array(["new model1", "new model2"])
      expect(user.printer_file).to match_array(["new type5", "new type6"])
      expect(user.orcid).to eq("https://orcid.org/1111-1111-1111-1111")
      expect(user.twitter_handle).to eq("new twitter")
      expect(user.facebook_handle).to eq("new facebook")
      expect(user.website).to eq("new website")
      expect(user.ms_id).to eq("msid678")
    end
  end
end
