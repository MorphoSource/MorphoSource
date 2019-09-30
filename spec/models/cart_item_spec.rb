require 'rails_helper'

RSpec.describe CartItem, type: :model do

  let(:current_user)  { User.create(id: 1, email: "example@email.com", password: "password") }

  let(:work1)         { Media.create(id: "aaa", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: ['restricted_download'])}
  let(:work2)         { Media.create(id: "bbb", title: ["Test Media Work"], depositor: "test@test.com", fileset_accessibility: [''])}

  let(:cartItem1)     { CartItem.create( user_id: current_user.id, work_id: work1.id, restricted: true) }
  let(:cartItem2)     { CartItem.create( user_id: current_user.id, work_id: work2.id, restricted: false) }

  before do
    cartItem1.touch
    cartItem2.touch
    allow(Media).to receive(:find).with(cartItem1.work_id).and_return(work1)
    allow(Media).to receive(:find).with(cartItem2.work_id).and_return(work2)
  end

  describe '#set_approver' do
     it 'assigns the work depositor as approver' do
       expect(cartItem1.approver).to eq(work1.depositor)
     end
  end

  describe '#unrestricted' do
    it 'returns true when restricted is false' do
      expect(cartItem2.unrestricted?).to be(true)
    end
    it 'returns false when restricted is true' do
      expect(cartItem1.unrestricted?).to be(false)
    end
  end

  describe '#request_status' do
    context 'user cancels the request' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_canceled = Date.today
      end
      it { expect(cartItem1.request_status).to eq('Canceled') }
    end
    context 'data owner denies the download request' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_denied = Date.today
      end
      it { expect(cartItem1.request_status).to eq('Denied') }
    end
    context 'an approved request has an expiration date in the past' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_approved = Date.yesterday
        cartItem1.date_expired = Date.yesterday
      end
      it { expect(cartItem1.request_status).to eq('Expired') }
    end
    context 'a request is approved by the data owner' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_approved = Date.yesterday
        cartItem1.date_expired = Date.tomorrow
      end
      it { expect(cartItem1.request_status).to eq('Approved') }
    end
    context 'a user has requested the item' do
      before do
        cartItem1.date_requested = Date.yesterday
      end
      it { expect(cartItem1.request_status).to eq('Requested') }
    end
    context 'a user has not yet requested a restricted item' do
        it { expect(cartItem1.request_status).to eq('Not Requested') }
    end
    context "an unrestricted item's status is downloadable" do
      it { expect(cartItem2.request_status).to eq('Downloadable') }
    end
  end

  describe '#downloadable?' do
    context 'the item is not restricted' do
      it { expect(cartItem2.downloadable?).to be(true) }
    end
    context 'a restricted item is approved' do
      before do
        allow(cartItem1).to receive(:request_status).and_return('Approved')
      end
      it { expect(cartItem1.downloadable?).to be(true) }
    end
    context 'a restricted item is not approved' do
      before do
        allow(cartItem1).to receive(:request_status).and_return('Denied')
      end
      it { expect(cartItem1.downloadable?).to be(false) }
    end
  end

  describe '#expired?' do
    context 'an approved item is not yet expired' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_approved = Date.yesterday
        cartItem1.date_expired = Date.tomorrow
      end
      it { expect(cartItem1.expired?).to be(false) }
    end
    context 'an approved item has passed its expiration date' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_approved = Date.yesterday
        cartItem1.date_expired = Date.yesterday
      end
      it { expect(cartItem1.expired?).to be(true) }
    end
    context 'an unrestricted item does not have an expiration date' do
      it { expect(cartItem2.expired?).to be(false) }
    end
  end

  describe '#editable?' do
    before do
      [cartItem1,cartItem1].each do |items|
        items.date_requested = Date.yesterday
      end
    end
    context 'item is approved' do
      before do
        cartItem1.date_approved = Date.today
      end
      it { expect(cartItem1.editable?).to be(true) }
      it { expect(cartItem2.editable?).to be(false) }
    end
    context 'item is expired' do
      before do
        cartItem2.date_approved = Date.today
        cartItem2.date_expired = Date.yesterday
      end
      it { expect(cartItem1.editable?).to be(false) }
      it { expect(cartItem2.editable?).to be(true) }
    end
    context 'item is denied' do
      before do
        cartItem1.date_denied = Date.today
      end
      it { expect(cartItem1.editable?).to be(false) }
      it { expect(cartItem2.editable?).to be(false) }
    end
    context 'item is cleared' do
      before do
        cartItem1.date_cleared = Date.today
        cartItem2.date_approved = Date.yesterday
      end
      it { expect(cartItem1.editable?).to be(false) }
      it { expect(cartItem2.editable?).to be(true) }
    end
  end
end
