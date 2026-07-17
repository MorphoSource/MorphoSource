require 'rails_helper'

RSpec.describe Morphosource::Facets::SolrTitleLookup do
  subject(:lookup) { Class.new { include Morphosource::Facets::SolrTitleLookup }.new }

  let(:connection) { instance_double(RSolr::Client) }

  before do
    allow(Blacklight.default_index).to receive(:connection).and_return(connection)
  end

  describe '#fetch_ids_by_title' do
    let(:response) { { 'response' => { 'docs' => [{ 'id' => 'matching-id' }] } } }

    it 'uses the model filter for every supported ID-backed facet' do
      expected_filters = {
        'team' => 'has_model_ssim:Collection AND human_readable_type_tesim:Team',
        'project' => 'has_model_ssim:Collection AND human_readable_type_tesim:Project',
        'media_list' => 'has_model_ssim:MediaList',
        'seq_section_list' => 'has_model_ssim:SequentialSectionList',
        'object' => 'has_model_ssim:(BiologicalSpecimen OR CulturalHeritageObject)',
        'organization' => 'has_model_ssim:OrganizationCollection',
        'device' => 'has_model_ssim:(DeviceResource)'
      }

      expected_filters.each do |facet_key, model_filter|
        expect(connection).to receive(:get).with(
          'select',
          params: {
            q: 'title_tesim:"matching title"',
            fq: [model_filter],
            fl: 'id',
            rows: 999999
          }
        ).and_return(response)

        expect(lookup.fetch_ids_by_title('matching title', facet_key)).to eq(['matching-id'])
      end
    end

    it 'returns nil without querying Solr when the title is blank' do
      expect(connection).not_to receive(:get)

      expect(lookup.fetch_ids_by_title(' ', 'team')).to be_nil
    end

    it 'returns an empty array when Solr finds no matching documents' do
      allow(connection).to receive(:get).and_return('response' => { 'docs' => [] })

      expect(lookup.fetch_ids_by_title('missing', 'team')).to eq([])
    end

    it 'escapes quotes and backslashes in the Solr phrase' do
      expect(connection).to receive(:get).with(
        'select',
        params: hash_including(q: 'title_tesim:"quoted \\"title\\" and \\\\ path"')
      ).and_return(response)

      lookup.fetch_ids_by_title('quoted "title" and \\ path', 'team')
    end
  end

  describe '#fetch_user_ids_by_name' do
    let!(:matching_user) do
      User.create!(email: 'matching@example.com', password: 'password', display_name: 'Matching User')
    end

    before do
      User.create!(email: 'different@example.com', password: 'password', display_name: 'Different User')
    end

    it 'performs a case-insensitive partial-name lookup and returns string IDs' do
      expect(lookup.fetch_user_ids_by_name('ATCHING')).to eq([matching_user.ms_id.to_s])
    end

    it 'returns nil when the name is blank' do
      expect(lookup.fetch_user_ids_by_name(nil)).to be_nil
    end
  end

  describe '#fetch_owner_ids_by_name' do
    it 'combines matching user and OrganizationCollection IDs' do
      allow(lookup).to receive(:fetch_user_ids_by_name).with('owner').and_return(['user-id'])
      allow(lookup).to receive(:fetch_ids_by_title).with('owner', 'organization').and_return(['org-id'])

      expect(lookup.fetch_owner_ids_by_name('owner')).to eq(%w[user-id org-id])
    end

    it 'returns nil without performing either lookup when the name is blank' do
      expect(lookup).not_to receive(:fetch_user_ids_by_name)
      expect(lookup).not_to receive(:fetch_ids_by_title)

      expect(lookup.fetch_owner_ids_by_name('')).to be_nil
    end
  end
end
