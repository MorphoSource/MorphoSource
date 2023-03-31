# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::CartItemsController, :type => :controller  do

  include_context 'cart items'

  describe "POST #create" do

    context 'item is not in cart and has not been requested' do
      let(:post_params) { {:work_id => work6.id } }

      it "creates a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
          }.to change{CartItem.count}.by(1)
      end

      it "creates the correct metadata" do
        post :create, params: post_params
        item = CartItem.last
        expect(item.user_id).to eq(current_user.ms_id)
        expect(item.work_id).to eq(work6.id)
        expect(item.in_cart).to be(true)
      end

      it "returns flash message 'Item Added to Cart'" do
        post :create, params: post_params
        expect(response.flash[:notice]).to eq('Item Added to Cart')
      end

      context 'work cannot be added to the cart' do
        before do
          work6.fileset_accessibility = ['private']
          work6.visibility = 'restricted'
          work6.save!
          allow(SolrDocument).to receive(:find).with(work6.id).and_return(SolrDocument.new(work6.to_solr))
        end
        context 'user does not have download access' do
          it 'returns flash message Download Unauthorized' do
            post :create, params: post_params
            expect(response.flash[:alert]).to eq('Download Unauthorized')
          end
        end
        context 'user has download access' do
          before do
            allow(subject.current_user).to receive(:can?).and_return(true)
          end
          it 'returns flash message Item Added to Cart' do
            post :create, params: post_params
            expect(response.flash[:notice]).to eq('Item Added to Cart')
          end
        end
      end
    end

    context 'item is not in cart and has already been requested' do
      let(:post_params) { {:work_id => work5.id} }

      it "finds the requested CartItem and moves it to the cart" do
        expect{
          process :create, method: :post, params: post_params
        }.to change{cartItem5.reload.in_cart}.from(false).to(true)
      end

      it "returns flash message 'Item Added to Cart'" do
        post :create, params: post_params
        expect(response.flash[:notice]).to eq('Previously Requested Item Moved to Cart')
      end
    end

    context 'item is already in cart' do
      let(:post_params) { {:work_id => work2.id} }

      it "Does not create a new CartItem" do
        expect{
          process :create, method: :post, params: post_params
        }.to change{CartItem.count}.by(0)
      end

      it "returns flash message 'Item Already in Cart'" do
        post :create, params: post_params
        expect(response.flash[:alert]).to eq('Item Already in Cart')
      end
    end
  end


  describe "POST #batch_create" do

    context '2 items not in cart , 1 item already in the cart' do
      let(:post_params) { {:batch_work_ids => [ work4.id, work6.id, work2.id ] } }

      it "creates new CartItems" do
        expect{
          process :batch_create, method: :post, params: post_params
          }.to change{CartItem.count}.by(2)
      end

      it "returns correct flash messages " do
        post :batch_create, params: post_params
        expect(response.flash[:notice]).to eq("2 items added to cart for download.  ")
        expect(response.flash[:alert]).to eq("1 item already in the cart for download.  ")
      end
    end
  end
end
