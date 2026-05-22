require 'rails_helper'
require 'iiif_manifest'

include ActionDispatch::TestProcess

RSpec.describe Morphosource::My::MediaCartsController, :type => :controller  do

  include_context 'cart items'

  before do
    Timecop.freeze(Time.local(1999, 9, 9, 9))
    allow(controller).to receive(:is_requests_page?).and_return(false)
  end

  after do
    Timecop.return
  end

  describe "GET #index" do

    before do
      get :index
    end

    include_examples '#index'
    include_examples '#get_items instance variables', 'media cart'

    it 'retrieves a formatted count of restricted items in the cart' do
      expect(subject.instance_variable_get(:@restricted_count)).to eq('1 Item')
    end

    it 'retrieves restricted items in the cart' do
      expect(subject.instance_variable_get(:@restricted_items)).to match_array([cartItem3])
    end

    it 'retrieves unrestricted items in the cart' do
      expect(subject.instance_variable_get(:@unrestricted_items)).to match_array([cartItem1,cartItem2])
    end

    it 'does not retrieve restricted items not in the cart' do
      expect(subject.instance_variable_get(:@restricted_items)).not_to include(cartItem5)
    end

    it 'does not retrieve unrestricted items not in the cart' do
      expect(subject.instance_variable_get(:@unrestricted_items)).not_to include(cartItem4,cartItem6)
    end
  end

  describe 'GET #download' do
    def download_keys_for_redirect
      uuid = Rack::Utils.parse_query(URI.parse(response.location).query)['download']
      session[:download_keys][uuid]
    end

    context 'the user uses the item download button to
    download one item' do
      context 'the item is unrestricted' do
        before do
          cartItem2.date_downloaded = nil
          cartItem2.save
          get :download, params: {item_id: cartItem2.id}
        end

        it "redirects to zip with the work id as params" do
          work_id = Media.find(cartItem2.work_id).access_control_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to contain_exactly(work_id)
        end
      end

      context 'the item is restricted' do
        before do
          get :download, params: {item_id: cartItem3.id}
        end

        it "redirects to zip with nil as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to be_empty
        end
      end
    end

    context 'the user batch-selects items to download' do
      context 'the selected items are unrestricted' do
        before do
          cartItem2.date_downloaded = nil
          cartItem2.save
          get :download, params: { batch_document_ids: [cartItem2.id] }
        end

        it "redirects to zip with the work ids as params" do
          work_id = Media.find(cartItem2.work_id).access_control_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to contain_exactly(work_id)
        end
      end

      context 'the selected items are restricted' do
        before do
          get :download, params: { batch_document_ids: [cartItem5.id,cartItem3.id] }
        end

        it "redirects to zip without the work ids as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to be_empty
        end
      end

      context 'the selected items are a mix of restricted and unrestricted' do
        before do
          cartItem2.date_downloaded = nil
          cartItem2.save
          get :download, params: { batch_document_ids: [cartItem2.id,cartItem3.id] }
        end

        it "redirects to zip with only the unrestricted work ids as params" do
          work_id = Media.find(cartItem2.work_id).access_control_id
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to contain_exactly(work_id)
        end
      end
    end

    context 'the user uses the download all button' do
      context 'the cart has only unrestricted items' do
        let(:unrestricted_work_ids)  { [
          Media.find(cartItem1.work_id).access_control_id,
          Media.find(cartItem2.work_id).access_control_id,
          Media.find(cartItem3.work_id).access_control_id
        ] }
        before do
          cartItem3.date_approved = Date.yesterday
          cartItem3.save
          get :download, params: {}
        end
        it "redirects to zip with all the work ids as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to match_array(unrestricted_work_ids)
        end
      end

      context 'the page has only restricted items' do
        before do
          cartItem1.date_approved = nil
          cartItem1.save
          work2.fileset_accessibility = ['restricted_download']
          work2.save!
          allow(SolrDocument).to receive(:find).with(work2.id).and_return(SolrDocument.new(work2.to_solr))
          get :download, params: {}
        end

        it "redirects to zip with none of the work ids as params" do
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to be_empty
        end
      end

      context 'the page has a mix of restricted and unrestricted items' do
        before do
          cartItem2.date_downloaded = nil
          cartItem2.save
          get :download, params: {}
        end

        it "redirects to media/#zip with only the unrestricted work ids as params" do
          work_ids = [
            Media.find(cartItem1.work_id).access_control_id,
            Media.find(cartItem2.work_id).access_control_id
          ]
          redirect_params = Rack::Utils.parse_query(URI.parse(response.location).query)
          expect(response).to redirect_to %r(\Ahttp://test.host/download?)
          expect(download_keys_for_redirect).to match_array(work_ids)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context 'the user batch selects items to destroy' do
      it "deletes the cart item if it hasn't been downloaded" do
        expect{
          process :destroy, method: :delete, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id]}
        [cartItem1,cartItem2].each(&:reload)
        expect(cartItem1.in_cart).to be(false)
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {:batch_document_ids => [cartItem3.id]}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        expect(response.flash[:notice]).to eq('3 Items Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {:batch_document_ids => [cartItem1.id,cartItem2.id,cartItem3.id]}
        expect(response).to redirect_to(my_cart_path)
      end
    end

    context 'removes one item using the individual button' do
      it "deletes the cart item if it hasn't been downloaded or requested" do
        expect{
          process :destroy, method: :delete, params: {:item_id => cartItem3.id}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {:item_id => cartItem2.id}
        cartItem2.reload
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {:item_id => cartItem3.id}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {:item_id => cartItem3.id}
        expect(response.flash[:notice]).to eq('1 Item Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {:item_id => cartItem3.id}
        expect(response).to redirect_to(my_cart_path)
      end
    end
    context 'removes all items using the clear cart button' do
      it "deletes the cart item if it hasn't been downloaded or requested" do
        expect{
          process :destroy, method: :delete, params: {}
        }.to change{CartItem.count}.by(-1)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been downloaded" do
        delete :destroy, params: {}
        [cartItem1,cartItem2].each(&:reload)
        expect(cartItem1.in_cart).to be(false)
        expect(cartItem2.in_cart).to be(false)
      end

      it "removes the cart item from the cart, but doesn't delete if it has been requested" do
        cartItem3.date_requested = Date.yesterday
        cartItem3.save
        delete :destroy, params: {}
        cartItem3.reload
        expect(cartItem3.in_cart).to be(false)
      end

      it "returns flash message 'Item Removed from Cart'" do
        delete :destroy, params: {}
        expect(response.flash[:notice]).to eq('3 Items Removed from Cart')
      end

      it "refreshes the my cart page" do
        delete :destroy, params: {}
        expect(response).to redirect_to(my_cart_path)
      end
    end
  end
end
