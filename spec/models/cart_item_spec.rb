require 'rails_helper'

RSpec.describe CartItem, type: :model do

  let(:user)          { User.create(email: "example@email.com", password: "password") }
  let(:reviewer)      { User.create(email: 'reviewer@email.com', password: 'password') }
  let(:depositor)     { User.create(email: 'depositor@email.com', password: 'password') }

  let(:work1)         { Media.create(id: "aaa", title: ["Test Media Work"], depositor: depositor.ms_id, download_reviewer: [reviewer.ms_id], fileset_accessibility: ['restricted_download'])}

  let(:work2)         { Media.create(id: "bbb", title: ["Test Media Work"], depositor: depositor.ms_id, download_reviewer: [], visibility: 'open', fileset_accessibility: ['open'])}

  let!(:cartItem1)    { CartItem.create(user: user, work_id: work1.id, reviewers: work1.reviewers) }
  let!(:cartItem2)    { CartItem.create(user: user, work_id: work2.id, reviewers: work2.reviewers) }

  before do
    Timecop.freeze(Time.local(1999, 9, 9, 9))
  end

  after do
    Timecop.return
  end

  describe '#active_request, #inactive_request' do
    context 'item is requested' do
      before do
        cartItem1.date_requested = Date.today
       cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(true) }
      it { expect(cartItem1.inactive_request?).to be(false) }
    end
    context 'item is approved' do
      before do
        cartItem1.date_requested = Date.today
        cartItem1.date_approved = Date.today
        cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(true) }
      it { expect(cartItem1.inactive_request?).to be(false) }
    end
    context 'item is cleared' do
      before do
        cartItem1.date_requested = Date.today
        cartItem1.date_cleared = Date.today
        cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(true) }
      it { expect(cartItem1.inactive_request?).to be(false) }
    end
    context 'item is canceled' do
      before do
        cartItem1.date_requested = Date.today
        cartItem1.date_canceled = Date.today
        cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(false) }
      it { expect(cartItem1.inactive_request?).to be(true) }
    end
    context 'item is denied' do
      before do
        cartItem1.date_requested = Date.today
        cartItem1.date_denied = Date.today
        cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(false) }
      it { expect(cartItem1.inactive_request?).to be(true) }
    end
    context 'item is expired' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_expired = Date.yesterday
        cartItem1.save
      end
      it { expect(cartItem1.active_request?).to be(false) }
      it { expect(cartItem1.inactive_request?).to be(true) }
    end
    context 'item is open' do
      it { expect(cartItem1.active_request?).to be(false) }
      it { expect(cartItem1.inactive_request?).to be(false) }
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
      it { expect(cartItem2.request_status).to eq('Not Requested') }
    end
  end

  describe '#editable?' do
    before do
      allow(cartItem2).to receive(:restricted?).and_return(true)
      [cartItem1,cartItem2].each do |items|
        items.date_requested = Date.yesterday
      end
    end
    context 'item is approved' do
      before do
        cartItem1.date_approved = Date.today
        cartItem1.date_expired = Date.tomorrow
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

  describe '#unrequested' do
    context 'item has been requested' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.save
      end
      it { expect(cartItem1.unrequested?).to be(false) }
    end
    context 'item has not been requested' do
      it { expect(cartItem1.unrequested?).to be(true) }
    end
  end

  describe '#cleared?' do
    context 'item has been cleared' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_cleared = Date.yesterday
        cartItem1.save
      end
      it { expect(cartItem1.cleared?).to be(true) }
    end
    context 'item has not been cleared' do
      it { expect(cartItem1.cleared?).to be(false) }
    end
  end

  describe '#work' do
    it 'is a solr document' do
      expect(cartItem1.work.class).to be(SolrDocument)
      expect(cartItem1.work.id).to eq(cartItem1.work_id)
      expect(cartItem2.work.class).to be(SolrDocument)
      expect(cartItem2.work.id).to eq(cartItem2.work_id)
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

  describe '#approved?' do
    context 'work is not approved' do
      it { expect(cartItem1.approved?).to be(false) }
    end
    context 'work is approved' do
      before do
        cartItem1.date_requested = Date.yesterday
        cartItem1.date_approved = Date.yesterday
        cartItem1.save
      end
      context 'work is expired' do
        before do
          cartItem1.date_expired = Date.yesterday
          cartItem1.save
        end
        it { expect(cartItem1.approved?).to be(false) }
      end
      context 'work is not expired' do
        it { expect(cartItem1.approved?).to be(true) }
      end
    end
  end

  describe '#downloadable?' do
    context 'work is open' do
      subject { cartItem2.downloadable? }
      it { expect(subject).to be(true) }
    end
    context 'work is restricted' do
      subject { cartItem1.downloadable? }
      context 'user has download access' do
        before do
          work1.download_users += [user]
          work1.save
        end
        it { expect(subject).to be(true) }
      end
      context 'user is the work download reviewer' do
        before do
          cartItem1.update(reviewers: [user.ms_id])
        end
        it { expect(subject).to be(true) }
      end
      context 'user is the depositor' do
        before do
          work1.depositor = user.ms_id
          work1.save
          allow(SolrDocument).to receive(:find).with(work1.id).and_return(SolrDocument.find(work1.id))
        end
        it { expect(subject).to be(true) }
      end
      context 'request is approved' do
        before do
          cartItem1.date_requested = Date.yesterday
          cartItem1.date_approved = Date.yesterday
          cartItem1.date_expired = Date.tomorrow
        end
        it { expect(subject).to be(true) }
      end
    end
  end

  describe '#user_is_reviewer_or_has_ownership?' do
    subject { cartItem1.user_is_reviewer_or_has_ownership? }
    context 'user is not the reviewer or owner' do
      it { expect(subject).to be(false) }
    end
    context 'user is the reviewer' do
      before do
        cartItem1.update(reviewers: [user.ms_id])
      end
      it { expect(subject).to be(true) }
    end
    context 'user is the owner' do
      before do
        work1.owner = user.ms_id
        work1.save
      end
      it { expect(subject).to be(true) }
    end
    context 'user is the depositor' do
      before do
        work1.depositor = user.ms_id
        work1.save
      end
      it { expect(subject).to be(true) }
    end
  end

  describe '#reviewer' do
    it { expect(cartItem1.reviewer).to eq([reviewer]) }
    it { expect(cartItem2.reviewer).to eq([depositor]) }

    it 'reads the reviewers column without querying the work solr document' do
      expect(SolrDocument).not_to receive(:find)
      expect(cartItem1.reviewer).to eq([reviewer])
    end
  end
end
