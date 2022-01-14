require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Admin::ContributorPetitionsController, :type => :controller do
  let(:user) { User.create(email: 'user@email.com', password: 'password')}
  let(:admin_user) { User.create(email: 'adminuser@email.com', password: 'password')}
  
  describe 'GET #current_applications' do
    before do 
      allow(controller).to receive(:current_user) { user }
    end

    context 'when user is admin' do
      before do
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'page loads successfully' do
        get :current_applications
        expect(response).to have_http_status(200)
      end
    end

    context 'when user is not admin' do
      it 'page is forbidden' do
        get :current_applications
        expect(response).to have_http_status(302)
        expect(response).to redirect_to('/?locale=en')
      end
    end
  end

  describe 'PATCH #decide_petition' do
    let(:petition) { ContributorPetition.new(
      user: user,
      reason: 'Application reason',
      user_affiliation: 'Test Org',
      user_department: 'Test Dept',
      user_demographics: ['Student (Post-Graduate)', 'Faculty (Grades K-7)'],
      user_demographics_other: 'Volunteer',
      user_advisor: 'Adviser name, affiliation, and email',
      contribution_amount: '1 GB',
      terms_agree: true,
      decision_required: true
    )}
    let(:petition_params) {
      { id: petition.id, contributor_petition: { decision_message: 'Test Message' } }
    }
    let!(:contributor_group) { Role.create(name: 'contributor') }

    before do 
      allow(controller).to receive(:current_user) { admin_user }
      petition.save!
    end

    context 'when user is admin' do
      before do
        allow(controller).to receive(:require_permissions) { true }
      end

      it 'can approve petition' do
        petition_params[:commit] = 'Approve'
        patch :decide_petition, params: petition_params
        petition.reload
        expect(petition.decision_state).to eq('approve')
        expect(petition.decision_message).to eq('Test Message')
        expect(petition.decision_by).to eq(admin_user.id.to_s)
        expect(petition.decision_required).to be false
        expect(user.contributor?).to be true
      end

      it 'can return petition' do
        petition_params[:commit] = 'Return'
        patch :decide_petition, params: petition_params
        petition.reload
        expect(petition.decision_state).to eq('return')
        expect(petition.decision_message).to eq('Test Message')
        expect(petition.decision_by).to eq(admin_user.id.to_s)
        expect(petition.decision_required).to be false
        expect(user.contributor?).to be false
      end

      it 'can deny petition' do
        petition_params[:commit] = 'Deny'
        patch :decide_petition, params: petition_params
        petition.reload
        expect(petition.decision_state).to eq('deny')
        expect(petition.decision_message).to eq('Test Message')
        expect(petition.decision_by).to eq(admin_user.id.to_s)
        expect(petition.decision_required).to be false
        expect(user.contributor?).to be false
      end

    end

    context 'when user is not admin' do
      it 'page access is forbidden' do
        patch :decide_petition, params: petition_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to('/?locale=en')
      end
    end
  end
end