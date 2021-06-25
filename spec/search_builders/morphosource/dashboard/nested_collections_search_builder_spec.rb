require 'rails_helper'

RSpec.describe Morphosource::Dashboard::NestedCollectionsSearchBuilder do
  let(:access)              { :edit }
  let(:collection)          { double('Collection') }
  let(:scope)               { double('Scope') }
  let(:nesting_attributes)  { double('Nesting Attributes') }
  let(:nest_direction)      { double('Nest Direction') }
  let!(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:solr_parameters)     { {} }

  let(:builder)             { described_class.new(access: access, collection: collection, scope: scope, nesting_attributes: nesting_attributes, nest_direction: nest_direction) }

  describe '.default_processor_chain' do
    it 'includes show_only_projects and show_only_parentless_collections' do
      expect(described_class.default_processor_chain).to include(:show_only_projects, :show_only_parentless_collections)
    end
    it 'does not include show_only_other_collections_of_the_same_collection_type' do
      expect(described_class.default_processor_chain).not_to include(:show_only_other_collections_of_the_same_collection_type)
    end
  end

  describe 'show_only_projects' do
    it 'filters by project collection type' do
      builder.show_only_projects(solr_parameters)
      expect(solr_parameters[:fq]).to eq(["_query_:\"{!field f=collection_type_gid_ssim}#{project_collection_type.gid}\""])
    end
  end

  describe 'show_only_parentless_collections' do
    it 'filters by parentless collections' do
      builder.show_only_parentless_collections(solr_parameters)
      expect(solr_parameters[:fq]).to eq(["-nesting_collection__parent_ids_ssim:*"])
    end
  end
 end
