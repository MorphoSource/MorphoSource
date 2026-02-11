require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::PreviousRequestsController, :type => :controller  do

  include_context 'cart items'

  describe 'PUT #edit_expiration' do
    let(:expiration_date) { "2020-10-20" }

    before do
      cartItem1.reviewers << current_user.ms_id
      cartItem1.save
      put :edit_expiration, params: { item_id: cartItem1.id, expiration_date: expiration_date }
      cartItem1.reload
    end

    it "marks the item's expiration date as yesterday" do
      expect(cartItem1.date_expired).to eq(expiration_date)
    end
    it 'records action_by' do
      expect(cartItem1.action_by).to eq(current_user.ms_id)
    end
    it "creates a flash message" do
      expect(response.flash[:notice]).to eq("Expiration Date Updated")
    end
    it "redirects to the request manager page" do
      expect(response).to redirect_to(previous_requests_path)
    end
  end

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['date_decided asc',
       'date_decided desc',
       'date_downloaded asc',
       'date_downloaded desc',
       'date_expired asc',
       'date_expired desc',
       'date_requested asc',
       'date_requested desc',
       'decision_users.display_name asc',
       'decision_users.display_name desc',
       'use asc',
       'use desc',
       'users.display_name asc',
       'users.display_name desc',
       'work_id asc',
       'work_id desc']
    end

    it 'includes custom sort parameters' do
      expect(subject.allowed_sort_parameters).to match_array(allowed_sort_params)
    end
  end
end