require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::ContributorPetitionsController, :type => :controller do
  let(:user)  { User.create(email: 'user@email.com', password: 'password') }
  let(:create_params) {
    { 
      contributor_petition: {
        reason: 'Application reason',
        user_affiliation: 'Test Org',
        user_department: 'Test Dept',
        user_demographics: ['Student (Post-Graduate)', 'Faculty (Grades K-7)'],
        user_demographics_other: 'Volunteer',
        user_advisor: 'Adviser name, affiliation, and email',
        contribution_amount: '1 GB',
        terms_agree: true
      }
    }
  }
  let(:create_params_missing_some) {
    { 
      contributor_petition: {
        reason: 'Application reason',
        user_affiliation: 'Test Org'
      }
    }
  }
  let(:update_params) {
    {
      contributor_petition: {
        reason: 'New application reason',
        user_affiliation: 'New Test Org',
        user_department: 'Test Dept',
        user_demographics: ['Student (Post-Graduate)', 'Faculty (Grades K-7)'],
        user_demographics_other: 'Volunteer',
        user_advisor: 'Adviser name, affiliation, and email',
        contribution_amount: '10 GB',
        terms_agree: true
      }
    }
  }
  let(:update_params_missing_some) {
    {
      contributor_petition: {
        reason: 'New application reason',
        user_affiliation: 'New Test Org'
      }
    }
  }

  describe 'POST #create' do
    before do
      allow(controller).to receive(:current_user) { user }
    end

    it "creates a new contributor petition" do
      post :create, params: create_params
      expect(ContributorPetition.count).to be 1
    end

    it "creates the correct attributes and requires petition decision" do
      post :create, params: create_params
      petition = ContributorPetition.last
      create_params[:contributor_petition].each do |attr, val|
        if attr == :user_demographics
          val = create_params[:contributor_petition][:user_demographics] + 
            Array(create_params[:contributor_petition][:user_demographics_other])
        end
        expect(petition.send(attr)).to eq(val)
      end
      expect(petition.decision_required).to be true
    end

    it 'throws an error if not all required attributes are present' do
      expect{
        post :create, params: create_params_missing_some
      }.to raise_error(ActionController::ParameterMissing)
    end

    it 'throws an error if terms are not agreed to' do
      create_params[:contributor_petition][:terms_agree] = false
      post :create, params: create_params
      expect(response.flash[:notice]).to eq('To submit contributor application, you must agree to the terms!')
      expect(ContributorPetition.count).to be 0
    end
  end

  describe 'PATCH #update' do
    let(:petition) { ContributorPetition.new(create_params[:contributor_petition].merge(user: user))}

    before do 
      allow(controller).to receive(:current_user) { user }
      petition.save!
    end

    it 'successfully updates attributes and requires petition decision' do
      patch :update, params: update_params.merge(id: petition.id)
      petition.reload
      expect(petition.reason).to eq('New application reason')
      expect(petition.user_affiliation).to eq('New Test Org')
      expect(petition.contribution_amount).to eq('10 GB')
      expect(petition.decision_required).to be true
      expect(response.flash[:notice]).to eq(nil)
    end

    it 'throws an error if not all required attributes are present' do
      expect{
        process :update, method: :patch, params: update_params_missing_some.merge(id: petition.id)
      }.to raise_error(ActionController::ParameterMissing)
    end

    it 'throws an error if terms are not agreed to' do
      update_params[:contributor_petition][:terms_agree] = false
      patch :update, params: update_params.merge(id: petition.id)
      expect(response.flash[:notice]).to eq('To submit contributor application, you must agree to the terms!')
      petition.reload
      expect(petition.reason).to_not eq('New application reason')
    end

    it 'throws an error if petition is denied' do
      petition.decision_state = 'deny'
      petition.save!
      patch :update, params: update_params.merge(id: petition.id)
      expect(response.flash[:notice]).to eq('Denied contributor applications may not be resubmitted!')
      petition.reload
      expect(petition.reason).to_not eq('New application reason')
    end
  end
end