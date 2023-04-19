require 'rails_helper'

RSpec.describe Morphosource::ChangeContentOwnerService do

  subject { described_class }

  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:new_owner) { User.create(email: 'newowner@email.com', password: 'password') }

  let(:file_set)  { FileSet.new() }

  describe '.call' do
    context 'depositor is current user_with_ownership' do
      let(:media)     { Media.create(title: ['media'], depositor: depositor.ms_id) }
      before do
        media.ordered_members << file_set
        media.edit_users = [depositor]
        media.save!
        InheritPermissionsJob.perform_now(media.id)
        file_set.reload
      end
      context 'reset == "true"' do
        it "assigns a new owner and removes the previous user_with_ownership's edit access" do
          subject.call(media, new_owner, "true")
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to eq([new_owner.ms_id])
          expect(media.read_users).to eq([depositor.ms_id])
          expect(file_set.edit_users).to eq([new_owner.ms_id])
          expect(file_set.read_users).to eq([depositor.ms_id])
        end
      end
      context 'reset == true' do
        it "assigns a new owner and removes the previous user_with_ownership's edit access" do
          subject.call(media, new_owner, "true")
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to eq([new_owner.ms_id])
          expect(media.read_users).to eq([depositor.ms_id])
          expect(file_set.edit_users).to eq([new_owner.ms_id])
          expect(file_set.read_users).to eq([depositor.ms_id])
        end
      end
      context 'reset == false' do
        it "assigns a new owner and allows the previous user_with_ownership to retain edit access" do
          subject.call(media, new_owner, false)
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to match_array([new_owner.ms_id, depositor.ms_id])
          expect(media.read_users).to eq([])
          expect(file_set.edit_users).to match_array([new_owner.ms_id, depositor.ms_id])
          expect(file_set.read_users).to eq([])
        end
      end
    end

    context 'owner is current user_with_ownership' do
      let(:old_owner) { User.create(email: 'oldowner@email.com', password: 'password') }
      let(:media)     { Media.create(title: ['media'], depositor: depositor.ms_id, owner: old_owner.ms_id) }
      
      before do
        media.ordered_members << file_set
        media.edit_users = [depositor, old_owner]
        media.save!
        InheritPermissionsJob.perform_now(media.id)
        file_set.reload
      end
      context 'reset == "true"' do
        it "assigns a new owner and removes the previous user_with_ownership's edit access" do
          subject.call(media, new_owner, "true")
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to match_array([new_owner.ms_id, depositor.ms_id])
          expect(media.read_users).to eq([old_owner.ms_id])
          expect(file_set.edit_users).to match_array([depositor.ms_id, new_owner.ms_id])
          expect(file_set.read_users).to eq([old_owner.ms_id])
        end
      end
      context 'reset == true' do
        it "assigns a new owner and removes the previous user_with_ownership's edit access" do
          subject.call(media, new_owner, "true")
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to match_array([new_owner.ms_id, depositor.ms_id])
          expect(media.read_users).to eq([old_owner.ms_id])
          expect(file_set.edit_users).to match_array([depositor.ms_id, new_owner.ms_id])
          expect(file_set.read_users).to eq([old_owner.ms_id])
        end
      end
      context 'reset == false' do
        it "assigns a new owner and allows the previous user_with_ownership to retain edit access" do
          subject.call(media, new_owner, false)
          expect(media.owner).to eq(new_owner.ms_id)
          expect(media.edit_users).to match_array([new_owner.ms_id, depositor.ms_id, old_owner.ms_id])
          expect(media.read_users).to eq([])
          expect(file_set.edit_users).to match_array([new_owner.ms_id, depositor.ms_id, old_owner.ms_id])
          expect(file_set.read_users).to eq([])
        end
      end
    end
  end
end
