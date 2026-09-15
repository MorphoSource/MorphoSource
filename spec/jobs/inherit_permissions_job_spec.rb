require 'rails_helper'

RSpec.describe InheritPermissionsJob do
  let(:user)   { create(:user) }
  let(:editor) { create(:user) }
  let(:reader) { create(:user) }
  let(:work) do
    media = create(:media)
    media.edit_users   = [editor.user_key]
    media.edit_groups  = ['group1']
    media.read_users   = [reader.user_key]
    media.read_groups  = ['group2']
    media.save!
    media
  end

  describe 'with an ActiveFedora FileSet' do
    let(:file_set) { create(:file_set, user: user) }

    before do
      work.members << file_set
      work.save!
    end

    it 'copies the work permissions onto the fileset' do
      described_class.perform_now(work)

      file_set.reload
      expect(file_set.edit_users).to include(editor.user_key)
      expect(file_set.edit_groups).to include('group1')
      expect(file_set.read_users).to include(reader.user_key)
      expect(file_set.read_groups).to include('group2')
    end

    it 'removes permissions the fileset has that the work no longer has' do
      file_set.edit_users += ['stale_editor']
      file_set.save!

      described_class.perform_now(work)

      expect(file_set.reload.edit_users).not_to include('stale_editor')
    end
  end

  describe 'with a Valkyrie FileSet' do
    let(:file_set) { create(:valkyrie_file_set, user: user) }

    before do
      work.valkyrie_member_ids = [file_set.id.to_s]
      work.save!
    end

    it 'does not raise, and copies the work permissions via PermissionManager' do
      expect { described_class.perform_now(work) }.not_to raise_error

      reloaded = Hyrax.query_service.find_by(id: file_set.id)
      expect(reloaded.edit_users.to_a).to include(editor.user_key)
      expect(reloaded.edit_groups.to_a).to include('group1')
      expect(reloaded.read_users.to_a).to include(reader.user_key)
      expect(reloaded.read_groups.to_a).to include('group2')
    end
  end
end
