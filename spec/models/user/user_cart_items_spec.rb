require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user)  { User.create(email: 'user@email.com', password: 'password') }
  let(:some_user) { User.create(email: 'some_user@email.com', password: 'password') }

  let(:restricted_work) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download']) }
  let(:restricted_work2) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download']) }
  let(:open_work) { Media.create(title: ['Open Work'], fileset_accessibility: ['open']) }

  describe '#has_download_access_or_approval?' do
    subject { user.has_download_access_or_approval?(restricted_work.id) }

    context 'user has download access' do
      before do
        restricted_work.download_users = [user.ms_id]
        restricted_work.save
      end
      it { expect(subject).to be(true) }
    end

    context 'user has an approved request' do
      let!(:cart_item) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: 1.year.from_now)}

      it { expect(subject).to be(true) }
    end

    context 'user does not have download access or an approved request' do

      it { expect(subject).to be(false) }
    end
  end

  describe '#approved_to_download?' do
    subject { user.approved_to_download?(restricted_work.id) }

    context 'user does not have an approved request' do
      it { expect(subject).to be(false) }
    end

    context 'user has an approved download' do
      let!(:cart_item) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: 1.year.from_now)}

      it{ expect(subject).to be(true) }
    end
  end

  describe "items in the user's media cart" do
    # items in cart
    let!(:cart_item1) { CartItem.create(user_id: user.ms_id, work_id: 'aaa', in_cart: true) }
    let!(:cart_item2) { CartItem.create(user_id: user.ms_id, work_id: 'bbb', in_cart: true) }
    let!(:cart_item3) { CartItem.create(user_id: user.ms_id, work_id: 'ccc', in_cart: true) }
    # item not in cart
    let!(:cart_item4) { CartItem.create(user_id: user.ms_id, work_id: 'ddd', in_cart: false) }

    describe "all items in the user's cart" do
      describe '#items_in_cart' do
        subject { user.items_in_cart }
        it 'contains only items in the cart' do
          expect(subject).to match_array([cart_item1, cart_item2, cart_item3])
          expect(subject).not_to include(cart_item4)
        end
      end

      describe '#work_ids_in_cart' do
        subject { user.work_ids_in_cart }
        it "returns the work ids of items in the user's shopping cart" do
          expect(subject).to match_array([cart_item1.work_id, cart_item2.work_id, cart_item3.work_id])
          expect(subject).not_to include(cart_item4.work_id)
        end
      end
    end

    describe "restricted items in the user's cart" do
      before do
        [cart_item1, cart_item2].each do |item|
          item.work_id = restricted_work.id
          item.save
        end
        cart_item3.work_id = open_work.id
        cart_item3.save
      end
      describe '#restricted_items_in_cart' do
        subject { user.restricted_items_in_cart }
        it "returns the restricted items in the user's cart" do
          expect(subject).to match_array([cart_item1,cart_item2])
        end
      end
      describe '#restricted_items_in_cart_ids' do
        subject { user.restricted_items_in_cart_ids }
        it "returns the restricted item ids in the user's cart" do
          expect(subject).to match_array([cart_item1.id,cart_item2.id])
        end
      end
    end
  end

  # items with date_requested or date_cleared
  describe "items the user has requested" do
    # requested items
    let!(:cart_item1) { CartItem.create(user_id: user.ms_id, work_id: 'aaa', date_requested: Date.yesterday) }
    let!(:cart_item2) { CartItem.create(user_id: user.ms_id, work_id: 'bbb', date_requested: Date.yesterday) }
    # cleared
    let!(:cart_item3) { CartItem.create(user_id: user.ms_id, work_id: 'ccc', date_cleared: Date.yesterday) }
    # not requested
    let!(:cart_item4) { CartItem.create(user_id: user.ms_id, work_id: 'ddd' ) }

    describe '#my_requests' do
      it { expect(user.my_requests).to match_array([cart_item1, cart_item2, cart_item3]) }
    end
  end

  describe "a user's active requests" do
    # active - requested, approved, or cleared
    # requested
    let!(:cart_item1) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday) }
    # approved
    let!(:cart_item2)  { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.tomorrow) }
    # cleared
    let!(:cart_item3)  { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_cleared: Date.yesterday) }
    # inactive - denied, canceled, expired, not requested
    # denied
    let!(:cart_item4) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_denied: Date.today) }
    # canceled
    let!(:cart_item5) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_canceled: Date.today) }
    # expired
    let!(:cart_item6) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.yesterday) }
    # not requested
    let!(:cart_item7) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id) }

    describe '#my_active_requests' do
      it { expect(user.my_active_requests).to match_array([cart_item1, cart_item2, cart_item3]) }
    end
  end

  describe 'items requested from the user' do
    let(:restricted_work) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download'], depositor: user.ms_id) }
    let(:restricted_work2) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download'], depositor: user.ms_id) }
    let(:restricted_work3) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download'], depositor: user.ms_id) }
    let(:restricted_work4) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download'], depositor: user.ms_id) }

    # requested items
    # requested
    let!(:cart_item1) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday) }

    # approved
    let!(:cart_item2) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work2.id, date_requested: Date.yesterday, date_approved: Date.yesterday) }
    # cleared
    let!(:cart_item3) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work3.id, date_cleared: Date.yesterday) }
    # denied
    let!(:cart_item4) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_denied: Date.yesterday) }
    # expired
    let!(:cart_item5) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.yesterday) }
    # canceled
    let!(:cart_item6) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_canceled: Date.today) }

    # not requested
    let!(:cart_item7) { CartItem.create(user_id: some_user.ms_id, work_id: restricted_work4.id ) }

#    describe '#requests' do
#      it { expect(user.requests).to match_array([cart_item1,cart_item2,cart_item3,cart_item4,cart_item5,cart_item6]) }
#    end
    describe '#previously_requested_items' do
      it { expect(user.previously_requested_items).to match_array([cart_item2,cart_item3,cart_item4,cart_item5,cart_item6])}
    end
  end

  describe 'items a user has downloaded' do
    # not downloaded
    let!(:cart_item1) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday) }
    # downloaded
    let!(:cart_item2) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_downloaded: Date.yesterday) }

    describe '#downloaded_items' do
      it "returns items the user has downloaded" do
        expect(user.downloaded_items).to match_array([cart_item2])
      end
    end
  end

  describe 'items a user can download' do
    # downloadable items
    # item is from an open work
    let!(:cart_item1)  { CartItem.create(user_id: user.ms_id, work_id: open_work.id) }
    # user has download access to restricted work
    let!(:restricted_work2) { Media.create(title: ['Restricted Work'], fileset_accessibility: ['restricted_download']) }
    let!(:cart_item2)  { CartItem.create(user_id: user.ms_id, work_id: restricted_work2.id) }
    # user has an approved request
    let!(:cart_item3)  { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.tomorrow) }

    # non-downloadable items
    # item is from a private work
    let!(:private_work) { Media.create(title: ['Restricted Work'], visibility: 'restricted', fileset_accessibility: ['private']) }
    let!(:cart_item4)  { CartItem.create(user_id: user.ms_id, work_id: private_work.id) }
    # item is from a private work
    # item status is not requested
    let!(:cart_item5) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id) }
    # item status is requested
    let!(:cart_item6) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.today) }
    # item status is cleared
    let!(:cart_item7) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_cleared: Date.today) }
    # item status is expired
    let!(:cart_item8) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.yesterday) }
    # item status is denied
    let!(:cart_item9) { CartItem.create(user_id: user.ms_id, work_id: restricted_work.id, date_requested: Date.yesterday, date_denied: Date.yesterday) }
    before do
      restricted_work2.download_users += [user]
      restricted_work2.save
    end
    describe 'downloadable items in the cart' do
      before do
        cart_item1.in_cart = true
        cart_item2.in_cart = false
        cart_item3.in_cart = true
        [cart_item1,cart_item2,cart_item3].each(&:save)
      end
      describe '#downloadable_items_in_cart' do
        it "returns the items the user is allowed to download that are in the user's cart" do
          expect(user.downloadable_items_in_cart).to match_array([cart_item1, cart_item3])
        end
      end
      describe '#downloadable_ids_in_cart' do
        it "returns the items ids the user is allowed to download that are in the user's cart" do
          expect(user.downloadable_ids_in_cart).to match_array([cart_item1.id, cart_item3.id])
        end
      end
    end
  end
end
