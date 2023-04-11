require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::RequestManagersController, :type => :controller  do

  include_context 'cart items'

  before do
    allow(subject).to receive(:email_sender) { User.first }
  end

  describe "GET #index" do

    let(:user1) { User.create(email: "user1@test.com", password: "password")}
    let(:user2) { User.create(email: "user2@test.com", password: "password")}
    let(:user3) { User.create(email: "user3@test.com", password: "password")}
    let(:user4) { User.create(email: "user4@test.com", password: "password")}

    before do
      cartItem1.user_id = user1.ms_id
      cartItem3.user_id = user2.ms_id
      cartItem5.user_id = user3.ms_id
      cartItem7.user_id = user4.ms_id
      cartItem1.reviewers = [current_user.ms_id]
      cartItem3.reviewers = [current_user.ms_id]
      cartItem5.reviewers = [current_user.ms_id]
      cartItem7.reviewers = [current_user.ms_id]
      [cartItem1,cartItem3,cartItem5,cartItem7].each(&:save)
      [work1,work3,work5,work7].each do |work|
        work.download_reviewer = [current_user.ms_id]
        work.save
      end
    end

    context 'normal index stuff' do
      before do
        get :index
      end
      include_examples '#index'
    end

    context 'user looks at new requests' do
      before do
        allow(subject).to receive(:previous_requests?).and_return(false)
        get :index
      end

      include_examples '#get_items instance variables', 'request manager'

      it 'retrieves the correct tab' do
        expect(subject.instance_variable_get(:@tab)).to eq('new')
      end

      it 'retrieves the correct requesters' do
        expect(subject.instance_variable_get(:@requesters)).to match_array([user3])
      end
    end

    context 'user looks at previous requests' do
      before do
        allow(subject).to receive(:previous_requests?).and_return(true)
        get :index
      end

      include_examples '#get_items instance variables', 'previous requests'

      it 'retrieves the correct tab' do
        expect(subject.instance_variable_get(:@tab)).to eq('previous')
      end

      it 'retrieves the correct requesters' do
        expect(subject.instance_variable_get(:@requesters)).to match_array([user1])
      end
    end
  end

  describe "PUT #approve_download" do
    let(:expiration_date) { "2020-10-20"}
    context 'the data manager approves one request' do
      before do
        put :approve_download, params: { item_id: cartItem1.id, expiration_date: expiration_date }
        cartItem1.reload
      end
      it "marks the item's date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
      end
      it "marks the item's date expired to one month from now" do
        expect(cartItem1.date_expired).to eq(expiration_date)
      end
      it 'records the current user in action_by' do
        expect(cartItem1.action_by).to eq(current_user.ms_id)
      end
      it "creates a flash message with the number of items approved" do
        expect(response.flash[:notice]).to eq("1 Item Approved for Download")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
    context 'the data manager approves multiple requests' do
      before do
        put :approve_download, params: { batch_document_ids: [cartItem1.id,cartItem5.id], expiration_date: expiration_date }
        [cartItem1,cartItem5].each(&:reload)
      end
      it "marks the items' date approved to today" do
        expect(cartItem1.date_approved.to_date).to eq(Date.today)
        expect(cartItem5.date_approved.to_date).to eq(Date.today)
      end
      it 'marks the items action_by with the approver ms_id' do
        expect(cartItem1.action_by).to eq(current_user.ms_id)
        expect(cartItem5.action_by).to eq(current_user.ms_id)
      end
      it "marks the items' date expired to one month from now" do
        expect(cartItem1.date_expired).to eq(expiration_date)
        expect(cartItem5.date_expired).to eq(expiration_date)
      end
      it "creates a flash message with the number of items approved" do
        expect(response.flash[:notice]).to eq("2 Items Approved for Download")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
    context 'messages fail to send' do
      before do
        allow(subject).to receive(:send_response_message).with(any_args).and_raise(NoMethodError)
        put :approve_download, params: { item_id: cartItem1.id, expiration_date: expiration_date }
      end
      it 'produces a flash error' do
        expect(response.flash[:error]).to eq(I18n.t('morphosource.dashboard.my.manage_requests.approved_request.messages.error'))
      end
    end
  end

  describe 'PUT #clear_request' do
    before do
      put :clear_request, params: { item_id: cartItem5.id }
      cartItem5.reload
    end
    it "clears the item's date requested" do
      expect(cartItem5.date_requested).to be(nil)
    end
    it 'marks the date cleared as today' do
      expect(cartItem5.date_cleared.to_date).to eq(Date.today)
    end
    it 'records action_by' do
      expect(cartItem5.action_by).to eq(current_user.ms_id)
    end
    it 'creates a flash message' do
      expect(response.flash[:notice]).to eq("Request cleared for 1 Item")
    end
    it 'redirects to the request manager page' do
      expect(response).to redirect_to(request_manager_path)
    end
    context 'messages fail to send' do
      before do
        allow(subject).to receive(:send_response_message).with(any_args).and_raise(NoMethodError)
        put :clear_request, params: { item_id: cartItem5.id }
        cartItem5.reload
      end
      it 'produces a flash error' do
        expect(response.flash[:error]).to eq(I18n.t('morphosource.dashboard.my.manage_requests.cleared_request.messages.error'))
      end
    end
  end

  describe "PUT #deny_download" do
    context 'it is successful' do
      before do
        put :deny_download, params: { item_id: cartItem5.id }
        cartItem5.reload
      end
      it "marks the item's date denied to today" do
        expect(cartItem5.date_denied.to_date).to eq(Date.today)
      end
      it 'records action_by' do
        expect(cartItem5.action_by).to eq(current_user.ms_id)
      end
      it "creates a flash message" do
        expect(response.flash[:notice]).to eq("Download Denied")
      end
      it "redirects to the request manager page" do
        expect(response).to redirect_to(request_manager_path)
      end
    end
    context 'messages fail to send' do
      before do
        allow(subject).to receive(:send_response_message).with(any_args).and_raise(NoMethodError)
        put :deny_download, params: { item_id: cartItem5.id }
      end
      it 'produces a flash error' do
        expect(response.flash[:error]).to eq(I18n.t('morphosource.dashboard.my.manage_requests.denied_request.messages.error'))
      end
    end
  end
end
