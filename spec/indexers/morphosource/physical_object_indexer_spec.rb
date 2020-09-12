require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectIndexer do
  let(:specimen)      { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ["Yes"]) }
  let(:organization)  { Organization.create(title: ['Organization']) }
  let(:media) { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow']) }
  let(:imaging_event) { ImagingEvent.create(title: ['title'])}
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 88) }
  let(:project) { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: 'msid', visibility: 'open') }
  let!(:works)  { [organization, specimen, imaging_event, media] }

  subject(:solr_document) { described_class.new(specimen).generate_solr_document }

  before do
    organization.ordered_members << specimen
    specimen.ordered_members << imaging_event
    imaging_event.ordered_members << media
    media.member_of_collections = [project]
    works.each(&:save)
    works.each(&:reload)
  end

  describe 'custom fields' do
    it 'indexes organization, media_type, media_collections, and media_keyword' do
      # organization
      expect(subject['organization_sim'][0]).to eq(organization.title[0])
      expect(subject['organization_tesim'][0]).to eq(organization.title[0])
      # media_type
      expect(subject['media_type_tesim'][0]).to eq(media.media_type[0])
      expect(subject['media_type_sim'][0]).to eq(media.media_type[0])
      # media_collections
      expect(subject['media_collections_tesim']).to eq(media.member_of_collections.map{|c| c.title.first })
      expect(subject['media_collections_sim']).to eq(media.member_of_collections.map{|c| c.title.first })
      # # media_keyword
      expect(subject['media_keyword_tesim']).to match_array(media.keyword)
      expect(subject['media_keyword_sim']).to match_array(media.keyword)
    end
  end
end
