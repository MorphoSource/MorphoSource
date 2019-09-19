require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Hyrax::MediaController, type: :controller do

  let(:public)      { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
  let(:private)     { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  let(:embargo)     { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO }
  let(:lease)       { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE }

  describe 'updating publication status updates all cart items' do
    let (:depositor)         { User.create(email: "test@test.com", password: "password")}
    let (:item_owner) { User.create(email: "test2@test.com", password: "password")}
    let (:open_work)        { Media.create(title: ["Example title"], depositor: depositor.email, fileset_accessibility: ["open"])}
    let (:restricted_work)        { Media.create(title: ["Example title"], depositor: depositor.email, fileset_accessibility: ["restricted_download"])}

    # unrestricted items
    let (:cartItem1)  { CartItem.create(user_id: item_owner.id, work_id: open_work.id, restricted: false)}
    let (:cartItem2)  { CartItem.create(user_id: item_owner.id, work_id: open_work.id, restricted: false)}
    let (:cartItem3)  { CartItem.create(user_id: item_owner.id, work_id: open_work.id, restricted: false)}
    let (:unrestrictedItems) {[cartItem1,cartItem2,cartItem3]}
    # restricted items
    let (:cartItem4)  { CartItem.create(user_id: item_owner.id, work_id: restricted_work.id, restricted: true)}
    let (:cartItem5)  { CartItem.create(user_id: item_owner.id, work_id: restricted_work.id, restricted: true)}
    let (:cartItem6)  { CartItem.create(user_id: item_owner.id, work_id: restricted_work.id, restricted: true)}
    let (:restrictedItems) {[cartItem4,cartItem5,cartItem6]}

    before do
      sign_in depositor
      allow(controller).to receive(:authorize!).and_return(true)
      allow(Media).to receive(:find).with(open_work.id).and_return(open_work)
      allow(Media).to receive(:find).with(restricted_work.id).and_return(restricted_work)
      allow(CartItem).to receive(:where).with(work_id: open_work.id).and_return(unrestrictedItems)
      allow(CartItem).to receive(:where).with(work_id: restricted_work.id).and_return(restrictedItems)
      allow(subject).to receive(:attributes_for_actor).and_return( { "media_type"=>["Image"]} )
    end

    context 'publication status does not change' do
      context 'the publication status is open' do
        before do
          allow(controller).to receive(:curation_concern).and_return(open_work)
          patch :update, params: { id: open_work, media: {visibility: public}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem1.restricted).to be(false)
          expect(cartItem2.restricted).to be(false)
          expect(cartItem3.restricted).to be(false)
        end
      end
      context 'the publication status is restricted' do
        before do
          allow(controller).to receive(:curation_concern).and_return(restricted_work)
          patch :update, params: { id: restricted_work, media: {visibility: "restricted_download"}, action: "update" }
          restrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem4.restricted).to be(true)
          expect(cartItem5.restricted).to be(true)
          expect(cartItem6.restricted).to be(true)
        end
      end
    end

    context 'publication status changes from open' do
      before do
        allow(controller).to receive(:curation_concern).and_return(open_work)
      end

      context 'to restricted' do
        before do
          patch :update, params: { id: open_work, media: {visibility: "restricted_download"}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'restricts all cart items' do
          expect(cartItem1.restricted).to be(true)
          expect(cartItem2.restricted).to be(true)
          expect(cartItem3.restricted).to be(true)
        end
      end

      context 'to preview' do
        before do
          patch :update, params: { id: open_work, media: {visibility: "preview"}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'restricts all cart items' do
          expect(cartItem1.restricted).to be(true)
          expect(cartItem2.restricted).to be(true)
          expect(cartItem3.restricted).to be(true)
        end
      end

      context 'to hidden' do
        before do
          patch :update, params: { id: open_work, media: {visibility: "hidden"}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'restricts all cart items' do
          expect(cartItem1.restricted).to be(true)
          expect(cartItem2.restricted).to be(true)
          expect(cartItem3.restricted).to be(true)
        end
      end

      context 'to private' do
        before do
          patch :update, params: { id: open_work, media: {visibility: private}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'restricts all cart items' do
          expect(cartItem1.restricted).to be(true)
          expect(cartItem2.restricted).to be(true)
          expect(cartItem3.restricted).to be(true)
        end
      end

      context 'to lease' do
        before do
          allow(controller).to receive(:publication_status_changed?).and_return(:true)
          allow(open_work).to receive(:active_lease?).and_return(true)
          allow(open_work).to receive(:visibility_during_lease).and_return("open")
          patch :update, params: { id: open_work, media: {visibility: lease}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem1.restricted).to be(false)
          expect(cartItem2.restricted).to be(false)
          expect(cartItem3.restricted).to be(false)
        end
      end
      context 'to embargo' do
        before do
          allow(controller).to receive(:publication_status_changed?).and_return(:true)
          allow(open_work).to receive(:under_embargo?).and_return(true)
          allow(open_work).to receive(:visibility_during_embargo).and_return("restricted")
          patch :update, params: { id: open_work, media: {visibility: embargo}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'restricts the cart items' do
          expect(cartItem1.restricted).to be(true)
          expect(cartItem2.restricted).to be(true)
          expect(cartItem3.restricted).to be(true)
        end
      end
    end

    context 'publication status changes from restricted' do
      before do
        allow(controller).to receive(:curation_concern).and_return(restricted_work)
      end

      context 'it changes to open' do
        before do
          patch :update, params: { id: restricted_work, media: {visibility: public}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'unrestricts all cart items' do
          expect(cartItem4.restricted).to be(false)
          expect(cartItem5.restricted).to be(false)
          expect(cartItem6.restricted).to be(false)
        end
      end

      context 'it changes to preview' do
        before do
          patch :update, params: { id: restricted_work, media: {visibility: "preview"}, action: "update" }
          unrestrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem4.restricted).to be(true)
          expect(cartItem5.restricted).to be(true)
          expect(cartItem6.restricted).to be(true)
        end
      end

      context 'to hidden' do
        before do
          patch :update, params: { id: restricted_work, media: {visibility: "hidden"}, action: "update" }
          restrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem4.restricted).to be(true)
          expect(cartItem5.restricted).to be(true)
          expect(cartItem6.restricted).to be(true)
        end
      end

      context 'to private' do
        before do
          patch :update, params: { id: open_work, media: {visibility: private}, action: "update" }
          restrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem4.restricted).to be(true)
          expect(cartItem5.restricted).to be(true)
          expect(cartItem6.restricted).to be(true)
        end
      end

      context 'to lease' do
        before do
          allow(controller).to receive(:publication_status_changed?).and_return(:true)
          allow(restricted_work).to receive(:active_lease?).and_return(true)
          allow(restricted_work).to receive(:visibility_during_lease).and_return("open")
          patch :update, params: { id: restricted_work, media: {visibility: lease}, action: "update" }
          restrictedItems.each(&:reload)
        end
        it 'unrestricts the cart items' do
          expect(cartItem4.restricted).to be(false)
          expect(cartItem5.restricted).to be(false)
          expect(cartItem6.restricted).to be(false)
        end
      end
      context 'to embargo' do
        before do
          allow(controller).to receive(:publication_status_changed?).and_return(:true)
          allow(restricted_work).to receive(:under_embargo?).and_return(true)
          allow(restricted_work).to receive(:visibility_during_embargo).and_return("restricted")
          patch :update, params: { id: restricted_work, media: {visibility: embargo}, action: "update" }
          restrictedItems.each(&:reload)
        end
        it 'does not change the cart items' do
          expect(cartItem4.restricted).to be(true)
          expect(cartItem5.restricted).to be(true)
          expect(cartItem6.restricted).to be(true)
        end
      end
    end
  end
end
