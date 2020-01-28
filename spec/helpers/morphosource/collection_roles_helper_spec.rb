require 'rails_helper'

RSpec.describe Morphosource::CollectionRolesHelper, type: :helper do

  before do
    helper.instance_variable_set(:@virtual_path, 'hyrax.dashboard.collections.form_share')
  end

  describe '#ms_access_options' do

    it 'returns options for manager, depositor, and viewer' do
      expect(helper.ms_access_options).to eq("<option value=\"managers\">Manager</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"viewers\">Viewer</option>")
    end
  end

  describe 'ms_edit_access_options' do
    context 'current managers' do
      it { expect(helper.ms_edit_access_options('managers')).to eq("<option value=\"depositors\">Depositor</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current depositors' do
      it { expect(helper.ms_edit_access_options('depositors')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"viewers\">Viewer</option>\n<option value=\"remove\">Remove</option>") }
    end
    context 'current viewers' do
      it { expect(helper.ms_edit_access_options('viewers')).to eq("<option value=\"managers\">Manager</option>\n<option value=\"depositors\">Depositor</option>\n<option value=\"remove\">Remove</option>") }
    end
  end

  describe '#collection_options' do
    let(:user) { User.new(email: 'email@email.com', password: 'password') }
    let(:collection1) { double('collection1', id: 'abc123', title: ['Collection1']) }
    let(:collection2) { double('collection2', id: 'def456', title: ['Collection2']) }
    let(:collection3) { double('collection3', id: 'ghi678', title: ['Collection3']) }
    before do
      allow(user).to receive(:collections_managed).and_return([collection1, collection2, collection3])
      helper.instance_variable_set(:@current_user, user)
      helper.instance_variable_set(:@collection, collection1)
    end

    it 'returns all collections managed by the current user except the current collection' do
      expect(helper.collection_options).to include(collection2.id, collection2.title.first, collection3.id, collection3.title.first)
      expect(helper.collection_options).to_not include(collection1.id, collection1.title.first)
    end
  end
end
