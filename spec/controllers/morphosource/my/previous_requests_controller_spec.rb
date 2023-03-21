require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::PreviousRequestsController, :type => :controller  do

  include_context 'cart items'

  describe 'PUT #edit_expiration' do
    let(:expiration_date) { "2020-10-20" }

    before do
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
end