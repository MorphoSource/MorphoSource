require 'rails_helper'

RSpec.describe Morphosource::CartItemHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe '#item_status_label and #item_action_button' do
    let(:depositor) { User.create(email: "test@test.com", password: "password")}
    let(:work)  { double('work', id: 'www', depositor: depositor.ms_id)}
    let(:item)  { CartItem.create( id: 'aaa', user_id: '555', work_id: work.id)}

    before do
      allow(Media).to receive(:find).with(work.id).and_return(work)
    end

    context 'the item is canceled' do
      let(:label_content) do
        %(<span class=\"label label-danger\" style=\"background-color: gray;\">Canceled</span>)
      end
      let(:button_content) do
        %(<button name=\"button\" type=\"submit\" id=\"request-button\" class=\"btn btn-info\" data-toggle=\"modal\" data-target=\"#pageModal\" data-item-id=\"0\">Request Download</button>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_canceled = Date.today
      end

      it 'creates a "Canceled" label' do
        expect(item_status_label(item)).to eq(label_content)
      end

      it 'creates a "Request Download" button' do
        expect(item_action_button(item)).to eq(button_content)
      end

    end

    context 'the request is denied' do
      let(:label_content) do
        %(<span class=\"label label-danger\" style=\"\">Denied</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-danger\" style=\"\" rel=\"nofollow\" data-method=\"delete\" href=\"/remove_from_cart?item_id=#{item.id}\">Remove from Cart</a>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_denied = Date.today
      end

      context 'the item is in the media cart' do
        before do
          item.in_cart = true
        end
        it 'creates a "Denied" label' do
          expect(item_status_label(item)).to eq(label_content)
        end
        it 'creates a "Remove from Cart" button' do
          expect(item_action_button(item)).to eq(button_content)
        end
      end

      context 'the item is not in the media cart' do
        let(:span) { content_tag(:span) }
        before do
          item.in_cart = false
        end
        it 'creates a "Denied" label' do
          expect(item_status_label(item)).to eq(label_content)
        end
        it 'creates an empty span tag' do
          expect(item_action_button(item)).to eq(span)
        end
      end
    end

    context 'the request approval is expired' do
      let(:label_content) do
        %(<span class=\"label label-warning\" style=\"background-color: orange;\">Expired</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-primary\" style=\"\" data-method=\"get\" href=\"/request_again?item_id=#{item.id}\">Request Again</a>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_approved = Date.yesterday
        item.date_expired = Date.yesterday
      end

      it 'creates an "Expired" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Request Again" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the request is approved' do
      let(:label_content) do
        %(<span class=\"label label-success\" style=\"\">Approved</span>)
      end
      before do
        item.date_requested = Date.yesterday
        item.date_approved = Date.yesterday
        item.date_expired = Date.tomorrow
      end

      it 'creates an "Approved" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
    end

    context 'the item status is requested' do
      let(:label_content) do
        %(<span class=\"label label-primary\" style=\"\">Requested</span>)
      end
      let(:button_content) do
        %(<a class=\"btn btn-danger\" style=\"background-color: gray;\" rel=\"nofollow\" data-method=\"put\" href=\"/cancel_request?item_id=#{item.id}\">Cancel Request</a>)
      end
      before do
        item.date_requested = Date.today
      end

      it 'creates a "Requested" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Cancel Request" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the item is not requested' do
      let(:label_content) do
        %(<span class=\"label label-info\" style=\"background-color: teal;\">Not Requested</span>)
      end
      let(:button_content) do
        %(<button name=\"button\" type=\"submit\" id=\"request-button\" class=\"btn btn-info\" data-toggle=\"modal\" data-target=\"#pageModal\" data-item-id=\"0\">Request Download</button>)
      end

      it 'creates a "Not Requested" label' do
        expect(item_status_label(item)).to eq(label_content)
      end
      it 'creates a "Request Download" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end

    context 'the item is downloadable' do
      let(:button_content) do
        %(<a class=\"btn btn-info\" style=\"\" data-method=\"get\" href=\"/download_items?item_id=#{item.id}\">Download Item</a>)
      end
      before do
        item.restricted = false
      end

      it 'creates a "Download Item" button' do
        expect(item_action_button(item)).to eq(button_content)
      end

    end
  end

  describe '#choose_download_button' do
    let(:current_user)          { double('user') }
    let(:downloadable_work_ids) { ['aaa','bbb','ccc'] }
    let(:requests_work_ids)     { ['ddd','eee','fff'] }

    before do
      allow(current_user).to receive(:downloadable_item_work_ids).and_return(downloadable_work_ids)
      allow(current_user).to receive(:my_active_requests_work_ids).and_return(requests_work_ids)
    end

    context "item is not in the user's cart OR item is in the user's cart but hasn't been requested" do
      it 'displays the request download button' do
        expect(choose_download_button('ggg')).to eq("<button name=\"button\" type=\"submit\" id=\"request-button\" class=\"btn btn-default\" data-toggle=\"modal\" data-target=\"#pageModal\" data-work-id=\"ggg\">Request Download</button>")
      end
    end
    context "item has been requested but not yet approved" do
      it 'displays the download requested button' do
        expect(choose_download_button('ddd')).to eq("<a class=\"btn btn-default\" role=\"button\" disabled=\"disabled\" href=\"\">Download Requested</a>")
      end
    end
    context "item is in the user's cart, has been requested, and has been approved" do
      it 'displays the download button' do
        expect(choose_download_button('aaa')).to eq("<a class=\"btn btn-default\" download=\"true\" target=\"_blank\" role=\"button\" id=\"file_download\" data-label=\"aaa\" href=\"/download_work?work_id%5B%5D=aaa\">Download</a>")
      end
    end
  end

  describe '#choose_cart_button' do
    let(:current_user)          { double('user') }
    let(:cart_works)            { ['aaa','bbb','ccc'] }
    let(:presenter1)            { double('presenter', id: 'aaa') }
    let(:presenter2)            { double('presenter', id: 'ddd') }

    before do
      allow(current_user).to receive(:work_ids_in_cart).and_return(cart_works)
      allow(current_user).to receive_message_chain(:media_cart,:id).and_return(555)
    end

    context "the work is in the user's cart" do
      it 'displays the item in cart button' do
        expect(choose_cart_button(presenter1)).to eq("<a class=\"btn btn-default\" href=\"/dashboard/my/cart\">Item in Cart</a>")
      end
    end
    context "the work is not in the user's cart" do
      it 'displays the add to cart button' do
        expect(choose_cart_button(presenter2)).to eq("<a class=\"btn btn-default\" rel=\"nofollow\" data-method=\"post\" href=\"/add_to_cart?work_id=ddd\">Add to Cart</a>")
      end
    end
  end

  describe 'page' do
    let(:request) { double("request")}
    before do
      allow(helper).to receive(:request).and_return(request)
      allow(helper.request).to receive(:fullpath).and_return(path)
    end

    context 'media cart page' do
      let(:path) { my_cart_path }
      it{ expect(page).to eq('cart') }
    end

    context 'requests page' do
      let(:path) { my_requests_path }
      it{ expect(page).to eq('requests') }
    end

    context 'request manager page' do
      let(:path) { request_manager_path }
      it{ expect(page).to eq('request_manager') }
    end

    context 'downloads page' do
      let(:path) { my_downloads_path }
      it{ expect(page).to eq('downloads') }
    end

    context 'previous requests page' do
      let(:path) { previous_requests_path }
      it{ expect(page).to eq('previous_requests') }
    end

  end
end
