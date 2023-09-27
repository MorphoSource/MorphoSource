require 'rails_helper'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::Dashboard::ProfilesController, :type => :controller  do

  let!(:user) { 
    FactoryBot.create(:user,
      email: "user@test.com",
      password: 'password',
      display_name: "Test User",
      affiliation: "Test Affiliation",
      department: "",
      address: "Test Address",
      country: "US",
      state: "NC",
      postal_code: "27278",
      telephone: "5555555555",
      demographics: ["demo1", "demo2"],
      intent: ["intent1", "intent2"],
      software: ["software1", "software2"],
      mesh_file_type: ["type1", "type2"],
      volume_file_type: ["type3","type4"],
      printer_model: ["model1", "model2"],
      printer_file: ["type5", "type6"],
      orcid: "https://orcid.org/0000-0000-0000-0000",
      twitter_handle: "@TestTest",
      facebook_handle: "test.test",
      website: "morphosource.org",
      terms_read: true,
      ms_id: "msid678") 
  }

  let!(:user2) { 
    FactoryBot.create(:user, 
      email: "user2@test.com", 
      password: 'password', 
      display_name: "Test User 2",
      profile_type: nil, 
      ms_id: "msid22") 
  }

  let(:admin_user) { FactoryBot.create(:admin) }

  let(:update_params) {
    { 
      user: {
        display_name: "New Display Name",
        affiliation: "New Affiliation",
        department: "",
        address: "New Address",
        country: "CA",
        state: "MB",
        postal_code: "New Code",
        telephone: "New Phone",
        demographics: ["newdemo1", "newdemo2", ""],
        intent: ["new intent1", "new intent2", ""],
        software: ["new software1", "new software2", ""],
        mesh_file_type: ["new type1", "new type2", ""],
        volume_file_type: ["new type3", "new type4", ""],
        printer_model: ["new model1", "new model2", ""],
        printer_file: ["new type5", "new type6", ""],
        orcid: "https://orcid.org/1111-1111-1111-1111",
        twitter_handle: "new twitter",
        facebook_handle: "new facebook",
        website: "new website",
        terms_read: true,
        sftp_share: 'testshare',
        profile_type: 'artist'},
      id: user.ms_id
    }
  }

  # params specifically for testing new user profile
  let(:update_params_new) {
    { 
      user: {
        first_name: "",
        middle_name: "",
        last_name: "",
        city: "",
        social_media_handles: "",
        typical_usage: "",
        profile_type: "",
        academic_institution_or_school: "",
        department: "",
        academic_field: "",
        academic_subfield: "",
        mentor_or_advisor: "",
        instructor: "",
        display_name: "New Display Name",
        affiliation: "New Affiliation",
        department: "New Department",
        address: "New Address",
        country: "",
        state: "",
        postal_code: "New Code",
        telephone: "New Phone",
        demographics: ["newdemo1", "newdemo2", ""],
        intent: ["new intent1", "new intent2", ""],
        software: ["new software1", "new software2", ""],
        mesh_file_type: ["new type1", "new type2", ""],
        volume_file_type: ["new type3", "new type4", ""],
        printer_model: ["new model1", "new model2", ""],
        printer_file: ["new type5", "new type6", ""],
        orcid: "https://orcid.org/1111-1111-1111-1111",
        twitter_handle: "new twitter",
        facebook_handle: "new facebook",
        website: "new website",
        terms_read: true,
        sftp_share: 'testshare',
        profile_type: nil},
      id: user2.ms_id
    }
  }

  let(:update_params_invalid_domain) { {user: {display_name: "New Display Name", affiliation: "New Affiliation", department: "New Department", address: "New Address", country: "CA", state: "MB", postal_code: "New Code", telephone: "New Phone", demographics: ["newdemo1", "newdemo2", ""], intent: ["new intent1", "new intent2", ""], software: ["new software1", "new software2", ""], mesh_file_type: ["new type1", "new type2", ""], volume_file_type: ["new type3", "new type4", ""], printer_model: ["new model1", "new model2", ""], printer_file: ["new type5", "new type6", ""], orcid: "https://orcid.org/1111-1111-1111-1111", twitter_handle: "new twitter", facebook_handle: "new facebook", website: "new website", terms_read: true, sftp_share: 'testshare'}, id: user.ms_id} }


  describe '#update' do

    context 'profile_type not valid' do
      before do
        sign_in user2
      end
      
      it 'redirects and returns profile_type not valid' do
        patch :update, params: update_params_new
        expect(response.status).to eq(302)
        expect(response.flash[:error]).to eq("Profile type not valid")
      end
    end

    context 'required universal fields not present' do
      before do
        sign_in user2
        update_params_new[:user][:profile_type] = "artist"
        update_params_new[:user][:department] = ""
      end

      it 'redirects and returns fields not present' do
        patch :update, params: update_params_new
        expect(response.status).to eq(302)
        expect(response.flash[:error]).to include("first_name is required", 
          "last_name is required", "Country is required", "State or Province is required")
      end
    end

    context 'profile_type not matched metadata' do
      before do
        sign_in user2
        update_params_new[:user][:profile_type] = "Faculty or Staff (K-12)"
      end

      it 'redirects and returns fields not matched with profile_type' do
        patch :update, params: update_params_new
        expect(response.status).to eq(302)
        expect(response.flash[:error]).to include("Organization cannot be present for profile type Faculty or Staff (K-12)", "first_name is required", "last_name is required", "Country is required", "State or Province is required", "academic_institution_or_school is required", "academic_field is required")
      end
    end

    context 'successful update' do

      before do
        sign_in user
        #allow(User).to receive(:from_url_component).with(update_params[:id]).and_return(user)
        #allow(User).to receive(:find).and_return(user)
      end

      it 'updates the user with MorphoSource attributes, and removes empty strings from multi-value attributes' do
        patch :update, params: update_params
        user.reload
        # check response.flash[:error] if fails here
        expect(user.display_name).to eq("New Display Name")
        expect(user.affiliation).to eq ("New Affiliation")
        expect(user.department).to eq("")
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
        expect(user.sftp_share).to eq("testshare")
        expect(user.profile_type).to eq('artist')
      end
    end
  end

  describe 'edit' do
    context 'user is not signed in' do
      it 'is redirects' do
        get :edit, params: { id: user.ms_id }
        expect(response.status).to eq(302)
      end
    end
    context 'non-admin user is signed in' do
      before do
        sign_in user
      end
      it 'is redirects to unauthorized when editing another user' do
        get :edit, params: { id: user2.ms_id }
        expect(response.status).to eq(401)
        expect(subject).to render_template("hyrax/base/unauthorized")
      end
      it 'is renders edit profile page when editing own profile' do
        get :edit, params: { id: user.ms_id }
        expect(response.status).to eq(200)
        expect(subject).to render_template("hyrax/dashboard/profiles/edit")
      end
    end
    context 'admin user is signed in' do
      before do
        sign_in admin_user
        allow(subject).to receive(:current_user).and_return(admin_user)
      end
      it 'is renders edit profile page when editing other user profile' do
        get :edit, params: { id: user.ms_id }
        expect(response.status).to eq(200)
        expect(subject).to render_template("hyrax/dashboard/profiles/edit")
      end
    end
  end

  describe 'edit_password' do
    context 'user is not signed in' do
      it 'is redirects' do
        get :edit_password, params: { id: user.ms_id }
        expect(response.status).to eq(302)
      end
    end
    context 'user is signed in' do
      before do
        sign_in user
      end
      it 'is renders edit_password' do
        get :edit_password, params: { id: user.ms_id }
        expect(response.status).to eq(200)
        expect(subject).to render_template("hyrax/dashboard/profiles/edit_password")
      end
    end
  end

  describe 'update_password' do
    let(:params)  { { id: user.ms_id, current_password: 'password', password: 'new_password', password_confirmation: 'new_password' } }
    context 'user is not signed in' do
      it 'redirects' do
        patch :update_password, params: params
        expect(response.status).to eq(302)
      end
    end
    context 'user is signed in' do
      before do
        sign_in user
      end
      context 'user enters wrong current password' do
        let(:params)  { { id: user.ms_id, user: { current_password: 'wrong_password', password: 'new_password', password_confirmation: 'new_password' } } }
        it 'redirects with an error' do
          patch :update_password, params: params
          expect(response.status).to eq(302)
          expect(response.flash[:alert]).to match_array(["Current password is invalid"])
        end
      end
      context 'user password and password confirmation do not match' do
        let(:params)  { { id: user.ms_id, user: { current_password: 'password', password: 'new_password', password_confirmation: 'another_new_password' } } }
        it 'redirects with an error' do
          patch :update_password, params: params
          expect(response.status).to eq(302)
          expect(response.flash[:alert]).to match_array(["Password confirmation doesn't match Password"])
        end
      end
      context 'user enters correct current password and password and password confirmation match' do
        let(:params)  { { id: user.ms_id, user: { current_password: 'password', password: 'new_password', password_confirmation: 'new_password' } } }
        it 'redirects to the profile page' do
          patch :update_password, params: params
          expect(response.status).to eq(302)
          expect(response.flash[:notice]).to eq("Your password has been updated")
        end
      end
    end
  end
end
