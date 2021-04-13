require 'rails_helper'

RSpec.describe Morphosource::CartItemHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe '#item_status_label and #item_action_button' do
    let(:depositor) { User.create(email: "test@test.com", password: "password") }
    let(:user)  { User.create(email: 'user@test.com', password: 'password') }
    let(:work)  { Media.create(title:['work'], id: 'www', depositor: depositor.ms_id, fileset_accessibility: ['restricted_download']) }
    let(:item)  { CartItem.create( id: 'aaa', user_id: user.ms_id, work_id: work.id) }

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
        %(<a class=\"btn btn-danger\" style=\"background-color: gray;\" rel=\"nofollow\" data-method=\"put\" href=\"/cancel_request?item_id=#{item.id}\">Cancel</a>)
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
        allow(item).to receive(:downloadable?).and_return(true)
      end

      it 'creates a "Download Item" button' do
        expect(item_action_button(item)).to eq(button_content)
      end
    end
  end

  describe '#choose_download_button' do
    let(:open_media)        { Media.create(title: ['open media'], visibility: 'open', fileset_accessibility: ['open']) }
    let(:restricted_media)  { Media.create(title: ['restricted media'], visibility: 'open', fileset_accessibility: ['restricted_download']) }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'user is not signed in' do
      let(:current_user)  { nil }

      context 'work is open' do
        before do
          assign(:curation_concern, open_media)
        end
        it 'displays the disabled download button' do
          expect(helper.choose_download_button).to eq("<a class=\"btn btn-default\" role=\"button\" style=\"flex-grow: 1;\" disabled=\"disabled\" href=\"javascript:void(0)\">Download</a>")
        end
      end

      context 'work is restricted download' do
        before do
          before do
            assign(:curation_concern, restricted_media)
          end
          it 'displays the disabled request download button' do
            expect(helper.choose_download_button).to eq("<a class=\"btn btn-default\" role=\"button\" style=\"flex-grow: 1;\" disabled=\"disabled\" href=\"\">Download</a>")
          end
        end
      end
    end

    context 'user is signed in' do
      let(:current_user) { User.create(email: 'email@email.com', password: 'password') }

      context 'work is open' do
        before do
          assign(:curation_concern, open_media)
        end

        it 'displays the download button' do
          expect(helper.choose_download_button).to eq("<a class=\"btn btn-default btn-download-item\" id=\"btn-download-item\" href=\"javascript:void(0)\">Download</a>")
        end
      end

      context 'work is restricted' do
        before do
          assign(:curation_concern, restricted_media)
        end

        it 'displays the request download button' do
          expect(helper.choose_download_button).to eq("<button name=\"button\" type=\"submit\" id=\"request-button\" class=\"btn btn-default\" data-toggle=\"modal\" data-target=\"#pageModal\" data-work-id=\"#{restricted_media.id}\">Request Download</button>")
        end

        context 'user has an approved cart item' do
          before do
            allow(current_user).to receive(:my_approved_requests_work_ids).and_return([restricted_media.id])
          end
          it 'returns the download button' do
            expect(helper.choose_download_button).to eq("<a class=\"btn btn-default btn-download-item\" id=\"btn-download-item\" href=\"javascript:void(0)\">Download</a>")
          end
        end

        context 'user has an unapproved cart item' do
          before do
            allow(current_user).to receive(:my_active_requests_work_ids).and_return([restricted_media.id])
          end

          it 'returns the download requested button' do
            expect(helper.choose_download_button).to eq("<a class=\"btn btn-default\" role=\"button\" disabled=\"disabled\" href=\"javascript:void(0)\">Download Requested</a>")
          end
        end

        context 'user has download access through a group' do
          let(:access_group)  { Role.create(name: 'access_group') }
          before do
            access_group.users << current_user
            access_group.save
            restricted_media.download_groups += [access_group]
            restricted_media.save
          end

          it 'returns the download button' do
            expect(helper.choose_download_button).to eq("<a class=\"btn btn-default btn-download-item\" id=\"btn-download-item\" href=\"javascript:void(0)\">Download</a>")
          end
        end
      end
    end
  end

  describe '#choose_cart_button' do
    let(:restricted_media)  { Media.create(title: ['restricted media'], visibility: 'open', fileset_accessibility: ['restricted_download']) }
    let(:private_media)     { Media.create(title: ['private media'], visibility: 'restricted', fileset_accessibility: ['private']) }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    context 'user is not signed in' do
      let(:current_user)  { nil }

      it 'returns the disabled add to cart button' do
        expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" role=\"button\" style=\"flex-grow: 1;\" disabled=\"disabled\" href=\"javascript:void(0)\">Add to Cart</a>")
      end
    end

    context 'the user is signed in' do
      let(:current_user)  { User.create(email: 'email@email.com', password: 'password') }

      before do
        assign(:curation_concern, restricted_media)
      end

      context 'media is private' do
        context 'user has view access only' do
          before do
            assign(:curation_concern, private_media)
          end

          it 'returns nothing' do
            expect(helper.choose_cart_button).to eq(nil)
          end
        end

        context 'user has edit access' do
          before do
            private_media.edit_users += [current_user]
            private_media.save
            assign(:curation_concern, private_media)
          end

          context 'media is not in the media cart' do
            before do
              allow(current_user).to receive(:work_ids_in_cart).and_return([])
            end

            it 'returns the add to cart button' do
              expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" rel=\"nofollow\" data-method=\"post\" href=\"/add_to_cart?work_id=#{private_media.id}\">Add to Cart</a>")
            end
          end

          context 'media is in the media cart' do
            before do
              allow(current_user).to receive(:work_ids_in_cart).and_return([private_media.id])
            end

            it 'returns the in cart button' do
              expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" href=\"/dashboard/my/cart\">Item in Cart</a>")
            end
          end
        end

        context 'user has download access' do
          before do
            private_media.download_users += [current_user]
            private_media.save
            assign(:curation_concern, private_media)
          end

          context 'media is not in the media cart' do
            before do
              allow(current_user).to receive(:work_ids_in_cart).and_return([])
            end

            it 'returns the add to cart button' do
              expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" rel=\"nofollow\" data-method=\"post\" href=\"/add_to_cart?work_id=#{private_media.id}\">Add to Cart</a>")
            end
          end

          context 'media is in the media cart' do
            before do
              allow(current_user).to receive(:work_ids_in_cart).and_return([private_media.id])
            end

            it 'returns the in cart button' do
              expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" href=\"/dashboard/my/cart\">Item in Cart</a>")
            end
          end
        end
      end

      context 'media is restricted download or open' do
        before do
          assign(:curation_concern, restricted_media)
        end

        context 'media is not in the user cart' do
          before do
            allow(current_user).to receive(:work_ids_in_cart).and_return([])
          end

          it 'returns the add to cart button' do
            expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" rel=\"nofollow\" data-method=\"post\" href=\"/add_to_cart?work_id=#{restricted_media.id}\">Add to Cart</a>")
          end
        end

        context 'media is in the user cart' do
          before do
            allow(current_user).to receive(:work_ids_in_cart).and_return([restricted_media.id])
          end

          it 'returns the in cart button' do
            expect(helper.choose_cart_button).to eq("<a class=\"btn btn-default\" href=\"/dashboard/my/cart\">Item in Cart</a>")
          end
        end
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

  describe 'action_by' do
    let(:user)      { User.create(email: 'user@email.com', password: 'password') }
    let(:approver)  {User.create(email: 'approver@email.com', password: 'password', display_name: 'approver name')}
    let(:item)      { CartItem.new(user_id: user.ms_id, work_id: 'work_id', action_by: nil ) }

    context 'action_by is nil' do
      it 'returns nil' do
        expect(action_by(item)).to be(nil)
      end
    end
    context 'action_by has approver id' do
      before do
        item.action_by = approver.ms_id
      end
      it 'returns the approver name' do
        expect(action_by(item)).to eq(approver.display_name)
      end
    end
  end

end
