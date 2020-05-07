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
        expect(item.restricted).to be(work6.restricted?)
        expect(item.approver_id).to eq(work6.reviewer)
      end

      it "returns flash message 'Item Added to Cart'" do
        post :create, params: post_params
        expect(response.flash[:notice]).to eq('Item Added to Cart')
      end

      context 'work is restricted' do
        before do
          allow(work6).to receive(:restricted?).and_return(true)
          post :create, params: post_params
        end

        it 'creates a restricted cart item' do
          item = CartItem.last
          expect(item.restricted).to be(true)
        end
      end

      context 'work is restricted but user is reviewer or depositor' do
        before do
          allow(work6).to receive(:restricted?).and_return(true)
        end
        context 'user is reviewer' do
          before do
            allow(work6).to receive(:download_reviewer).and_return([current_user.ms_id])
            post :create, params: post_params
          end
          it 'changes the item to unrestricted' do
            item = CartItem.last
            expect(item.restricted).to be(false)
          end
        end
        context 'user is depositor' do
          before do
            allow(work6).to receive(:depositor).and_return(current_user.ms_id)
            post :create, params: post_params
          end
          it 'changes the item to unrestricted' do
            item = CartItem.last
            expect(item.restricted).to be(false)
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

  describe '#GET download' do
    let(:testwork)         { Media.create(id: 'xxx', title: ["Test Media Work"], depositor: depositor.ms_id)}
    let(:cart_item)     { CartItem.create( user_id: current_user.ms_id, work_id: testwork.id ) }

    before do
      allow(Media).to receive(:find).with(testwork.id).and_return(testwork)
    end

    context 'the work is restricted' do
      let(:get_params) {{:intended_use => ["Intended Use"], :work_id => [testwork.id]}}
      before do
        testwork.fileset_accessibility = ["restricted_download"]
        testwork.save
        cart_item.restricted = true
        cart_item.save
      end
      context 'the user has an item in their cart for the work' do
        before do
          cart_item.in_cart = true
          cart_item.save
        end
        context 'the item is approved' do
          before do
            cart_item.date_requested = Date.yesterday
            cart_item.date_approved = Date.today
            cart_item.save
          end
          context 'the item has already been downloaded' do
            before do
              cart_item.date_downloaded = Date.yesterday
              cart_item.save
            end
            it 'creates a new downloaded cart item with the correct metadata' do
              expect{
                process :download, method: :get, params: get_params
              }.to change{CartItem.count}.by(1)

              item = CartItem.last
              expect(item.date_downloaded.to_date).to eq(Date.today)
              expect(item.restricted).to be(true)
              expect(item.work_id).to eq(testwork.id)
              expect(item.date_requested).to be(nil)
            end
            it 'does not change the date downloaded on the original item' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded.to_date).to eq(Date.yesterday)
            end
          end
          context 'the item has not been downloaded' do
            it 'marks the item as downloaded' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded).to_not be(nil)
            end
          end
          context 'the user is the approver for the item' do
            before do
              cart_item.approver_id = current_user.ms_id
              cart_item.save
            end
            context 'the item has not been downloaded' do
              it 'marks the item as downloaded' do
                get :download, params: get_params
                expect(cart_item.reload.date_downloaded).to_not be(nil)
              end
              it 'does not create a new cart item' do
                expect{
                  process :download, method: :get, params: get_params
                }.not_to change{CartItem.count}
              end
            end
            context 'the item has been downloaded' do
              before do
                cart_item.date_downloaded = Date.yesterday
                cart_item.save
              end
              it 'creates a new cart item with the correct metadata' do
                expect{
                  process :download, method: :get, params: get_params
                }.to change{CartItem.count}.by(1)

                item = CartItem.last
                expect(item.date_downloaded.to_date).to eq(Date.today)
                expect(item.restricted).to be(true)
                expect(item.work_id).to eq(testwork.id)
                expect(item.date_requested).to be(nil)
              end
            end
          end
        end
      end
      context 'the user has an approved item for the work not in their cart' do
        before do
          cart_item.in_cart = false
          cart_item.save
        end
        context 'the item is an approved request' do
          before do
            cart_item.date_requested = Date.yesterday
            cart_item.date_approved = Date.yesterday
            cart_item.save
          end
          context 'the item has been downloaded' do
            before do
              cart_item.date_downloaded = Date.yesterday
              cart_item.save
            end
            it 'creates a new cart item with the correct metadata' do
              expect{
                process :download, method: :get, params: get_params
              }.to change{CartItem.count}.by(1)

              item = CartItem.last
              expect(item.date_downloaded.to_date).to eq(Date.today)
              expect(item.restricted).to be(true)
              expect(item.work_id).to eq(testwork.id)
              expect(item.date_requested).to be(nil)
            end
            it 'does not change the date downloaded for the original item' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded.to_date).to eq(Date.yesterday)
            end
          end
          context 'the item has not been downloaded' do
            it 'marks the item as downloaded' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded.to_date).to eq(Date.today)
            end
          end
        end
      end
      context 'the user has an item in their cart and an inactive request' do
        let(:cart_item2) { CartItem.create(user_id: current_user.ms_id, work_id: testwork.id, in_cart: false, date_requested: Date.yesterday, date_canceled: Date.yesterday) }
        before do
          cart_item.in_cart = true
          cart_item.save
        end
        context 'the item in their cart is approved' do
          before do
            cart_item.date_requested = Date.yesterday
            cart_item.date_approved = Date.yesterday
            cart_item.save
          end
          context 'the item in the cart has been downloaded' do
            before do
              cart_item.date_downloaded = Date.yesterday
              cart_item.save
            end
            it 'creates a new cart item with the correct metadata' do
              expect{
                process :download, method: :get, params: get_params
              }.to change{CartItem.count}.by(1)

              item = CartItem.last
              expect(item.date_downloaded.to_date).to eq(Date.today)
              expect(item.restricted).to be(true)
              expect(item.work_id).to eq(testwork.id)
              expect(item.date_requested).to be(nil)
            end
            it 'does not change the original cart items' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded.to_date).to eq(Date.yesterday)
              expect(cart_item2.reload.date_downloaded).to be(nil)
            end
          end
          context 'the item in the cart has not been downloaded' do
            it 'marks the item in the cart as downloaded' do
              get :download, params: get_params
              expect(cart_item.reload.date_downloaded.to_date).to eq(Date.today)
            end
            it 'does not create a new cart item' do
              expect{
                process :download, method: :get, params: get_params
              }.not_to change{CartItem.count}
            end
            it 'does not alter the item not in the cart' do
              get :download, params: get_params
              expect(cart_item2.reload.date_downloaded).to be(nil)
            end
          end
        end
      end
    end
    context 'the work is unrestricted' do
      let(:get_params) {{:intended_use => ["Intended Use"], :work_id => [testwork.id]}}
      before do
        testwork.fileset_accessibility = [""]
        testwork.save
        cart_item.restricted = false
        cart_item.save
      end

      context 'the user has an item in their cart' do
        before do
          cart_item.in_cart = true
          cart_item.save
        end
        context 'the item has not been downloaded' do
          it 'marks the item as downloaded' do
            get :download, params: get_params
            expect(cart_item.reload.date_downloaded.to_date).to eq(Date.today)
          end
          it 'does not create another cart item' do
            expect{
              process :download, method: :get, params: get_params
            }.not_to change{CartItem.count}
          end
        end
        context 'the item has been downloaded' do
          before do
            cart_item.date_downloaded = Date.yesterday
            cart_item.save
          end
          it 'creates a new downloaded item with the correct metadata' do
            expect{
              process :download, method: :get, params: get_params
            }.to change{CartItem.count}.by(1)

            item = CartItem.last
            expect(item.date_downloaded.to_date).to eq(Date.today)
            expect(item.restricted).to be(false)
            expect(item.work_id).to eq(testwork.id)
            expect(item.date_requested).to be(nil)
          end
        end
      end
      context 'the user does not have an item in their cart' do
        before do
          cart_item.destroy
        end
        context 'the user has downloaded the work before' do
          let(:cart_item3) { CartItem.create( user_id: current_user.id, work_id: testwork.id, in_cart: false, date_downloaded: Date.yesterday) }

          it 'creates a new downloaded item' do
            expect{
              process :download, method: :get, params: get_params
            }.to change{CartItem.count}.by(1)
          end
        end
        context 'the user has not downloaded the work before' do
          it 'creates a new downloaded item' do
            expect{
              process :download, method: :get, params: get_params
            }.to change{CartItem.count}.by(1)
          end
        end
      end
    end
  end
end
