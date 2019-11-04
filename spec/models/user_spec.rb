require 'rails_helper'

RSpec.describe User, type: :model do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:data_owner)    { User.create(email: "test@test.com", password: "password") }

  let(:work)          { Media.create(id: "aaa", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['open'])}

  let(:work2)         { Media.create(id: "bbb", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['restricted_download'])}

  let(:work3)          { Media.create(id: "ccc", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['open'])}

  let(:work4)         { Media.create(id: "ddd", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['restricted_download'])}

  let(:work5)          { Media.create(id: "eee", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['open'])}

  let(:work6)         { Media.create(id: "fff", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['restricted_download'])}

  let(:cartItem1)     { CartItem.create(id: 1, user_id: user.id, work_id: "bbb", date_cleared: Time.current) }
  let(:cartItem2)     { CartItem.create(id: 2, user_id: user.id, work_id: "ccc") }
  let(:cartItem3)     { CartItem.create(id: 3, user_id: user.id, work_id: "ddd", date_requested: Date.yesterday) }
  let(:cartItem4)     { CartItem.create(id: 4, user_id: user.id, work_id: "eee", in_cart: false, date_downloaded: Time.current) }
  let(:cartItem5)     { CartItem.create(id: 5, user_id: user.id, work_id: "fff", in_cart: false, date_downloaded: Time.current, date_requested: Date.yesterday) }

  let(:allCartItems)  { [cartItem1, cartItem2, cartItem3, cartItem4, cartItem5] }

  before do
    allow(Media).to receive(:find).with('aaa').and_return(work)
    allow(Media).to receive(:find).with('bbb').and_return(work2)
    allow(Media).to receive(:find).with('ccc').and_return(work3)
    allow(Media).to receive(:find).with('ddd').and_return(work4)
    allow(Media).to receive(:find).with('eee').and_return(work5)
    allow(Media).to receive(:find).with('fff').and_return(work6)
    # Makes user aware of its cart_items
    allCartItems.each(&:touch)
  end

  describe '#items_in_cart' do
    it "returns all cart items in the user's shopping cart" do
      expect(user.items_in_cart).to match_array([cartItem1, cartItem2, cartItem3])
    end
  end

  describe '#work_ids_in_cart' do
    it "returns the work ids of items in the user's shopping cart" do
      expect(user.work_ids_in_cart).to match_array([cartItem1.work_id, cartItem2.work_id, cartItem3.work_id])
    end
  end

  describe '#restricted_items_in_cart' do
    it { expect(user.restricted_items_in_cart).to match_array([cartItem1,cartItem3])}
  end

  describe '#restricted_items_in_cart_ids' do
    it { expect(user.restricted_items_in_cart_ids).to match_array([cartItem1.id,cartItem3.id])}
  end

  # where user is requestor
  describe '#my_requests' do
    it { expect(user.my_requests).to match_array([cartItem1,cartItem3,cartItem5])}
  end

  describe '#my_requests_ids' do
    it { expect(user.my_requests_ids).to match_array([cartItem1.id,cartItem3.id,cartItem5.id])}
  end

  describe '#my_requests_work_ids' do
    it { expect(user.my_requests_work_ids).to match_array([cartItem1.work_id,cartItem3.work_id,cartItem5.work_id])}
  end

  # where user is data owner/manager
  describe '#requested_items' do
    it { expect(data_owner.requested_items).to match_array([cartItem1,cartItem3,cartItem5])}
  end

  describe '#requested_item_ids' do
    it { expect(data_owner.requested_item_ids).to match_array([cartItem1.id,cartItem3.id,cartItem5.id])}
  end

  describe '#requested_items_work_ids' do
    it { expect(data_owner.requested_items_work_ids).to match_array([cartItem1.work_id,cartItem3.work_id,cartItem5.work_id])}
  end

  describe '#newly_requested_items_user_ids' do
    it { expect(data_owner.newly_requested_items_user_ids.uniq).to match_array([user.id]) }
  end

  describe '#previously_requested_items_user_ids' do
    it { expect(data_owner.previously_requested_items_user_ids.uniq).to match_array([user.id]) }
  end

  describe '#downloaded_items' do
    it "returns items the user has downloaded" do
      expect(user.downloaded_items).to match_array([cartItem4, cartItem5])
    end
  end

  describe '#downloaded_work_ids' do
    it "returns the work ids for items the user has downloaded" do
      expect(user.downloaded_work_ids).to match_array([cartItem4.work_id, cartItem5.work_id])
    end
  end

  describe '#downloadable_items' do
    it 'returns the items the user is allowed to download' do
      expect(user.downloadable_items).to match_array([cartItem2,cartItem4])
    end
  end
  describe '#downloadable_ids' do
    it 'returns the ids for items the user is allowed to download' do
      expect(user.downloadable_ids).to match_array([cartItem2.id, cartItem4.id])
    end
  end
  describe '#downloadable_item_work_ids' do
    it 'returns the work ids for items the user is allowed to download' do
      expect(user.downloadable_item_work_ids).to match_array([cartItem2.work_id, cartItem4.work_id])
    end
  end
  describe '#downloadable_items_in_cart' do
    it "returns the items the user is allowed to download that are in the user's cart" do
      expect(user.downloadable_items_in_cart).to match_array([cartItem2])
    end
  end
  describe '#downloadable_ids_in_cart' do
    it "returns the items ids the user is allowed to download that are in the user's cart" do
      expect(user.downloadable_ids_in_cart).to match_array([cartItem2.id])
    end
  end

  describe '#my_active_requests, #my_active_requests_work_ids, #previously_requested_items' do

    let(:cartItem11)  { CartItem.new(id: 11, work_id: 'jjj', date_requested: Date.today)} #status = "Requested"
    let(:cartItem12)  { CartItem.new(id: 12, work_id: 'kkk', date_requested: Date.today, date_approved: Date.today)} #status = "Approved"
    let(:cartItem13)  { CartItem.new(id: 13, work_id: 'lll', date_requested: nil, date_cleared: Date.today)} #status = "Cleared"
    let(:cartItem14)  { CartItem.new(id: 14, work_id: 'mmm', date_requested: Date.today, date_denied: Date.today)} #status = "Denied"
    let(:cartItem15)  { CartItem.new(id: 15, work_id: 'nnn', date_requested: Date.today, date_approved: Date.today, date_expired: Date.yesterday )} #status = "Expired"
    let(:cartItem16)  { CartItem.new(id: 16, work_id: 'ooo', date_requested: Date.today, date_canceled: Date.today)} #status = "Canceled"
    let(:cart_items)  { [cartItem11,cartItem12,cartItem13,cartItem14,cartItem15,cartItem16] }

    before do
      allow(user).to receive(:cart_items).and_return(cart_items)
    end

    describe '#my_active_requests' do
      it 'returns the items that have been requested, approved, or cleared' do
        expect(user.my_active_requests).to match_array([cartItem11,cartItem12,cartItem13])
      end
      it 'does not return the items that have been denied, canceled, or are expired' do
        expect(user.my_active_requests).not_to include(cartItem14,cartItem15,cartItem16)
      end
    end

    describe '#my_active_requests_work_ids' do
      it 'returns the work ids for items that have been requested, approved, or cleared' do
        expect(user.my_active_requests_work_ids).to match_array([cartItem11.work_id,cartItem12.work_id,cartItem13.work_id])
      end
      it 'does not return the work ids for items that have been denied, canceled, or are expired' do
        expect(user.my_active_requests_work_ids).not_to include(cartItem14.work_id,cartItem15.work_id,cartItem16.work_id)
      end
    end

    describe '#previously_requested_items' do
      before do
        allow(data_owner).to receive(:requested_items).and_return(cart_items)
      end

      it 'returns the items that have status approved, denied, expired, cleared, and canceled' do
        expect(data_owner.previously_requested_items).to match_array([cartItem12, cartItem13,cartItem14,cartItem15,cartItem16])
      end
      it { expect(data_owner.previously_requested_items).not_to include([cartItem11])}
    end

    describe '#check_ms_id' do
      let(:new_user1) { User.new(email: "testemail@email.com", password: "password")}
      let(:old_ms_id) { "abc123" }
      let(:new_user2) { User.new(email: "another@email.com", password: "password", ms_id: old_ms_id)}
      before do
        [new_user1, new_user2].each(&:save)
        [new_user1, new_user2].each(&:reload)
      end
      it 'assigns an ms_id to new users without one' do
        expect(new_user1.ms_id).to_not be(nil)
      end
      it 'does not assign an ms_id to users who already have one' do
        expect(new_user2.ms_id).to eq(old_ms_id)
      end
    end
  end
end
