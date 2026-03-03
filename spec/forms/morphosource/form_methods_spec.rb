require 'rails_helper'

RSpec.describe Morphosource::FormMethods do

  let(:work) { Media.new }
  let(:controller) { instance_double(Hyrax::MediaController) }
  let(:form) { Hyrax::MediaForm.new(work, nil, controller) }
  let(:parent_work) { Media.create(title: ["Example Parent Work"], id: "ParentWork") }
  let(:parent_id) { parent_work.id }
  let(:parent_path) { "parent path" }

  before do
    allow(controller).to receive(:params).and_return(parent_id: parent_id)
    allow(controller).to receive(:url_for).and_return(parent_path)
  end

  describe "#member_of_works_json" do
    subject { form.member_of_works_json }

    it { is_expected.to include("ParentWork") }
    it { is_expected.to include("Example Parent Work") }

  end

  describe '#build_permitted_params' do
    it 'returns extended params even when no super is defined' do
      dummy_class = Class.new do
        include Morphosource::FormMethods
      end
      params = dummy_class.new.build_permitted_params

      expect(params).to include(:on_behalf_of, :version, :add_works_to_collection, :organization_institution)
      expect(params).to include(hash_including(work_parents_attributes: [:id, :_destroy]))
    end
  end

  describe '#member_of_organizations_json' do
    let(:dummy_model) { instance_double('Model', organization_id: organization_id) }
    let(:dummy_form) do
      Class.new do
        include Morphosource::FormMethods
        def initialize(model)
          @model = model
        end
        attr_reader :model
      end.new(dummy_model)
    end

    context 'when organization_id is blank' do
      let(:organization_id) { [] }

      it 'returns an empty array json' do
        expect(dummy_form.member_of_organizations_json).to eq([].to_json)
      end
    end

    context 'when organization collection exists' do
      let(:organization_id) { ['org-1'] }
      let(:org_collection) { instance_double('OrganizationCollection', id: 'org-1', title: ['Org Title']) }

      before do
        allow(OrganizationCollection).to receive(:exists?).with('org-1').and_return(true)
        allow(OrganizationCollection).to receive(:find).with('org-1').and_return(org_collection)
      end

      it 'returns organization collection json' do
        result = JSON.parse(dummy_form.member_of_organizations_json)
        expect(result).to eq([{ 'id' => 'org-1', 'label' => 'Org Title' }])
      end
    end

    context 'when organization id is not an organization collection' do
      let(:organization_id) { ['org-1'] }

      before do
        allow(OrganizationCollection).to receive(:exists?).with('org-1').and_return(false)
      end

      it 'returns an empty array json' do
        expect(dummy_form.member_of_organizations_json).to eq([].to_json)
      end
    end
  end

  describe '#member_of_taxonomies_json' do
    let(:dummy_model) { instance_double('Model', in_works: []) }
    let(:dummy_form) do
      Class.new do
        include Morphosource::FormMethods
        def initialize(model, controller)
          @model = model
          @controller = controller
        end
        attr_reader :model
      end.new(dummy_model, controller)
    end
    let(:query_service) { instance_double('Hyrax::QueryService') }
    let(:parent) do
      instance_double(
        'Taxonomy',
        id: 'tax-1',
        to_s: 'Taxonomy 1',
        taxonomy_domain: ['domain'],
        taxonomy_kingdom: ['kingdom'],
        taxonomy_phylum: ['phylum'],
        taxonomy_superclass: ['superclass'],
        taxonomy_class: ['class'],
        taxonomy_subclass: ['subclass'],
        taxonomy_superorder: ['superorder'],
        taxonomy_order: ['order'],
        taxonomy_suborder: ['suborder'],
        taxonomy_superfamily: ['superfamily'],
        taxonomy_family: ['family'],
        taxonomy_subfamily: ['subfamily'],
        taxonomy_tribe: ['tribe'],
        taxonomy_genus: ['genus'],
        taxonomy_subgenus: ['subgenus'],
        taxonomy_species: ['species'],
        taxonomy_subspecies: ['subspecies'],
        gbif_key: ['gbif'],
        depositor: 'depositor'
      )
    end

    before do
      allow(controller).to receive(:params).and_return(parent_id: 'tax-1')
      allow(controller).to receive(:url_for).and_return('path')
      allow(Hyrax).to receive(:query_service).and_return(query_service)
      allow(query_service).to receive(:find_by).with(id: 'tax-1').and_return(parent)
    end

    it 'uses Hyrax.query_service for parent lookup' do
      result = JSON.parse(dummy_form.member_of_taxonomies_json)
      expect(result.first['id']).to eq('tax-1')
      expect(result.first['path']).to eq('path')
    end
  end
end
