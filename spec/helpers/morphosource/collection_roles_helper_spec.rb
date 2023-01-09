# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::CollectionRolesHelper, type: :helper do
  before do
    helper.instance_variable_set(:@virtual_path, 'hyrax.dashboard.collections.form_share')
  end

  describe '#ms_access_options' do
    it 'returns options for manager, editor, depositor, downloader, and viewer' do
      expect(helper.ms_access_options).to eq("<option value=\"managers\">Manager</option>\n<option value=\"editors\">Editor</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"downloaders\">Downloader</option>\n<option value=\"viewers\">Viewer</option>")
    end
  end

  describe 'list_access_options' do
    it 'returns options for manager and viewer' do
      expect(helper.list_access_options).to match_array([["Manager", "managers"], ["Viewer", "viewers"]])
    end
  end

  describe 'ms_edit_access_options' do
    context 'current managers' do
      it { expect(helper.ms_edit_access_options('managers')).to eq("<option value=\"editors\">Editor</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"downloaders\">Downloader</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current editors' do
      it { expect(helper.ms_edit_access_options('editors')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"downloaders\">Downloader</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current depositors' do
      it { expect(helper.ms_edit_access_options('depositors')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"editors\">Editor</option>\n<option value=\"downloaders\">Downloader</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current downloaders' do
      it { expect(helper.ms_edit_access_options('downloaders')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"editors\">Editor</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current viewers' do
      it { expect(helper.ms_edit_access_options('viewers')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"editors\">Editor</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"downloaders\">Downloader</option>\n<option value=\"remove\">Remove</option>") }
    end
  end

  describe '#collection_options' do
    let!(:user) { User.create(email: 'email@email.com', password: 'password') }
    let!(:project_type) { Hyrax::CollectionType.create(title: "Project") }
    let!(:collection1) { Collection.create(title: ['Collection1'], collection_type_gid: project_type.gid, depositor: user.ms_id) }
    let!(:collection2) { Collection.create(title: ['Collection2'], collection_type_gid: project_type.gid, depositor: user.ms_id) }
    let!(:collection3) { Collection.create(title: ['Collection3'], collection_type_gid: project_type.gid, depositor: user.ms_id) }
    let(:collections) { [collection1, collection2, collection3] }
    before do
      collections.each { |c| c.create_collection_groups }
      helper.instance_variable_set(:@current_user, user)
      helper.instance_variable_set(:@collection, collection1)
    end

    it 'returns all collections managed by the current user except the current collection' do
      expect(helper.collection_options).to include(collection2.id, collection2.title.first, collection3.id, collection3.title.first)
      expect(helper.collection_options).to_not include(collection1.id, collection1.title.first)
    end
  end
end
