# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MsFileSetIndexer do
  let(:file_set)        { FileSet.create }
  let(:download_group1) { double('Role', name: '123_downloaders') }
  let(:download_group2) { double('Role', name: '456_downloaders') }
  let(:download_user1)  { double('User', ms_id: 'abc') }
  let(:download_user2)  { double('User', ms_id: 'def') }
  let(:download_groups) { [download_group1.name, download_group2.name] }
  let(:download_users)  { [download_user1.ms_id, download_user2.ms_id] }

  subject(:solr_document)   { described_class.new(file_set).generate_solr_document }

  before do
    allow(file_set).to receive(:download_groups).and_return(download_groups)
    allow(file_set).to receive(:download_users).and_return(download_users)
  end

  it 'indexes download groups and users' do
    expect(subject['download_access_group_ssim']).to match_array(download_groups)
    expect(subject['download_access_person_ssim']).to match_array(download_users)
  end
end
