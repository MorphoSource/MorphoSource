require 'redlock'
require 'rails_helper'

RSpec.describe Hyrax::Actors::FileSetActor do
  include ActionDispatch::TestProcess
  let(:user)          { User.new(id: 1) }
  let(:work)          { Media.new(title: ["Test Media Work"]) }

  describe "#attach_to_work" do
    context 'the work visibility is public' do
      let(:file_set)      { FileSet.create }
      let(:actor)         { described_class.new(file_set, user) }

      before do
        allow(actor).to receive(:acquire_lock_for).and_yield
        work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end

      context 'when the user wants the same visibility for the work and files' do
        before do
          work.fileset_visibility = [""]
        end
        it 'copies file_set visibility from the parent' do
          actor.attach_to_work(work)
          expect(file_set.reload.visibility).to eq(work.visibility)
        end
      end

      context 'when the user wants the file visibility to be private' do
        before do
          work.fileset_visibility = ["restricted"]
        end
        it 'assigns a private visibility to the file' do
          actor.attach_to_work(work)
          expect(file_set.reload.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end
      end
    end

    context 'the work visibility is embargoed' do
      let (:file_set_params) { {:visibility=>"restricted",
                                :visibility_during_lease=>"open", :visibility_after_lease=>"restricted", :lease_expiration_date=> (Time.zone.today + 2).to_s,
                                :embargo_release_date=> (Time.zone.today + 2).to_s, :visibility_during_embargo=>"restricted", :visibility_after_embargo=>"open"} }
      let(:file_set)         { FileSet.create(attributes: file_set_params) }
      let(:actor)             { described_class.new(file_set, user) }

      before do
        allow(actor).to receive(:acquire_lock_for).and_yield
        work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        work.visibility_during_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        work.visibility_after_embargo = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
        work.embargo_release_date = (Time.zone.today + 2).to_s
      end

      context 'when the user wants the same visibility for the work and files' do

        before do
          work.fileset_visibility = [""]
        end

        it 'copies file_set visibility from the parent' do
          actor.attach_to_work(work)
          expect(file_set.reload.visibility).to eq(work.visibility) 
          expect(file_set.reload.embargo_id).not_to be(nil)
        end
      end

      context 'when the user wants the file visibility to be private' do
        before do
          work.fileset_visibility = ["restricted"]
          actor.attach_to_work(work)
        end
        it 'assigns a private visibility to the file' do
          expect(file_set.reload.visibility).to eq Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
        end
        it 'removes the embargo_id from the file_set' do
          expect(file_set.reload.embargo_id).to eq(nil)
        end
      end
    end
  end
end
