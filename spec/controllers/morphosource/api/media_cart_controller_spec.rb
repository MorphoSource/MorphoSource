require 'rails_helper'

RSpec.describe Morphosource::Api::MediaCartController, type: :controller do

  # Provides current_user with cart items:
  #   in cart:     cartItem1 (approved request, downloadable), cartItem2 (open, downloadable),
  #                cartItem3 (restricted)
  #   not in cart: cartItem4..cartItem7
  include_context 'cart items'

  let(:other_user)      { User.create(email: 'other@email.com', password: 'password') }
  let!(:other_cartItem) { CartItem.create(user_id: other_user.ms_id, work_id: work2.id, in_cart: true, reviewers: [depositor.ms_id]) }

  let(:json)          { JSON.parse(response.body) }
  let(:returned_items) { json.dig('response', 'media_cart') }
  let(:returned_ids)  { returned_items.map { |i| i['id'] } }

  before do
    allCartItems
    # API requests must authenticate via API key, not a browser session
    sign_out current_user
  end

  def get_with_key(token, params = {})
    request.env['HTTP_AUTHORIZATION'] = token if token
    get :index, params: params, format: :json
  end

  describe 'GET #index' do
    context 'without an API key' do
      before { get_with_key(nil) }

      it 'returns 401 unauthorized' do
        expect(response).to have_http_status(401)
        expect(response.content_type).to include('application/json')
        expect(json['message']).to eq('Authentication Required')
      end
    end

    context 'with an invalid API key' do
      before { get_with_key('not-a-real-token') }

      it 'returns 401 unauthorized' do
        expect(response).to have_http_status(401)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with a valid API key' do
      before { get_with_key(current_user.token) }

      it 'returns 200 with JSON' do
        expect(response).to have_http_status(200)
        expect(response.content_type).to include('application/json')
      end

      it "returns only items in the user's media cart" do
        expect(returned_ids).to match_array([cartItem1.id, cartItem2.id, cartItem3.id])
      end

      it 'does not return items no longer in the cart' do
        expect(returned_ids).not_to include(cartItem4.id, cartItem5.id, cartItem6.id, cartItem7.id)
      end

      it "does not return other users' cart items" do
        expect(returned_ids).not_to include(other_cartItem.id)
      end

      it 'returns media metadata and status for each item' do
        item = returned_items.find { |i| i['id'] == cartItem1.id }
        expect(item['media_id']).to eq(work1.id)
        expect(item['media_title']).to eq('Test Media Work')
        expect(item['media_available']).to eq(true)
        expect(URI.parse(item['media_url']).path).to eq("/concern/media/#{work1.id}")
        expect(URI.parse(item['media_api_url']).path).to eq("/api/media/#{work1.id}")
        expect(item['downloadable']).to eq(true)
        expect(item['restricted']).to eq(false)
        expect(item['request_status']).to eq('Approved')
        expect(item['date_added']).to be_present
        expect(item['date_requested']).to be_present
        expect(item['date_approved']).to be_present
        expect(item['date_expired']).to be_present
        expect(item['date_downloaded']).to be_present
      end

      it 'marks restricted items as not downloadable' do
        item = returned_items.find { |i| i['id'] == cartItem3.id }
        expect(item['downloadable']).to eq(false)
        expect(item['restricted']).to eq(true)
        expect(item['request_status']).to eq('Not Requested')
        expect(item['date_requested']).to be_nil
        expect(item['date_downloaded']).to be_nil
      end

      it 'returns pagination info' do
        pages = json.dig('response', 'pages')
        expect(pages['current_page']).to eq(1)
        expect(pages['total_count']).to eq(3)
        expect(pages['total_pages']).to eq(1)
        expect(pages['limit_value']).to eq(described_class::DEFAULT_PER_PAGE)
        expect(pages['first_page?']).to eq(true)
        expect(pages['last_page?']).to eq(true)
      end
    end

    context 'when the user has an empty cart' do
      before do
        other_cartItem.update(in_cart: false)
        get_with_key(other_user.token)
      end

      it 'returns an empty list' do
        expect(response).to have_http_status(200)
        expect(returned_items).to eq([])
        expect(json.dig('response', 'pages', 'total_count')).to eq(0)
      end
    end

    context 'when a cart item references media that no longer exists' do
      let!(:orphan_item) { CartItem.create(user_id: current_user.ms_id, work_id: 'deleted-media', in_cart: true) }

      before do
        allow(SolrDocument).to receive(:find).with('deleted-media').and_raise(Blacklight::Exceptions::RecordNotFound)
        get_with_key(current_user.token)
      end

      it 'still returns the item, marked as unavailable' do
        item = returned_items.find { |i| i['id'] == orphan_item.id }
        expect(item['media_id']).to eq('deleted-media')
        expect(item['media_available']).to eq(false)
        expect(item['media_title']).to be_nil
        expect(item['media_url']).to be_nil
        expect(item['downloadable']).to eq(false)
      end
    end

    describe 'access filter' do
      it 'returns only downloadable items when access=downloadable' do
        get_with_key(current_user.token, access: 'downloadable')
        expect(returned_ids).to match_array([cartItem1.id, cartItem2.id])
      end

      it 'returns only restricted items when access=restricted' do
        get_with_key(current_user.token, access: 'restricted')
        expect(returned_ids).to match_array([cartItem3.id])
      end

      it 'returns 400 for an invalid access value' do
        get_with_key(current_user.token, access: 'bogus')
        expect(response).to have_http_status(400)
        expect(json['errors']).to include(a_string_including('access must be one of'))
      end
    end

    describe 'pagination' do
      it 'limits results with per_page' do
        get_with_key(current_user.token, per_page: 2)
        expect(returned_items.length).to eq(2)
        pages = json.dig('response', 'pages')
        expect(pages['total_count']).to eq(3)
        expect(pages['total_pages']).to eq(2)
        expect(pages['next_page']).to eq(2)
      end

      it 'returns subsequent pages' do
        get_with_key(current_user.token, per_page: 2, page: 2)
        expect(returned_items.length).to eq(1)
        expect(json.dig('response', 'pages', 'current_page')).to eq(2)
        expect(json.dig('response', 'pages', 'last_page?')).to eq(true)
      end

      it 'does not repeat items across pages' do
        get_with_key(current_user.token, per_page: 2, page: 1)
        first_page = returned_ids
        request.env['HTTP_AUTHORIZATION'] = current_user.token
        get :index, params: { per_page: 2, page: 2 }, format: :json
        second_page = JSON.parse(response.body).dig('response', 'media_cart').map { |i| i['id'] }
        expect(first_page + second_page).to match_array([cartItem1.id, cartItem2.id, cartItem3.id])
      end

      it 'caps per_page at the maximum' do
        get_with_key(current_user.token, per_page: described_class::MAX_PER_PAGE + 1)
        expect(json.dig('response', 'pages', 'limit_value')).to eq(described_class::MAX_PER_PAGE)
      end

      it 'returns 400 for a non-numeric page' do
        get_with_key(current_user.token, page: 'abc')
        expect(response).to have_http_status(400)
        expect(json['errors']).to include('page must be a positive integer')
      end

      it 'returns 400 for a zero per_page' do
        get_with_key(current_user.token, per_page: 0)
        expect(response).to have_http_status(400)
        expect(json['errors']).to include('per_page must be a positive integer')
      end
    end
  end
end
