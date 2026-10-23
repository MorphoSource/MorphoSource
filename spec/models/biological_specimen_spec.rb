# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe BiologicalSpecimen do

  describe 'metadata' do

    it_behaves_like 'a Morphosource work'

    # attributes shared between specimens and chos
    it_behaves_like 'a work with physical object metadata'

    # attributes unique to specimens
    it 'has biological specimen descriptive metadata' do
      expect(subject.attributes.keys).to include( "canonical_taxonomy",
                                                  "idigbio_recordset_id",
                                                  "idigbio_uuid",
                                                  "is_type_specimen",
                                                  "occurrence_id",
                                                  "sex",
                                                  "taxonomy_id" )
    end
  end

  describe "valid work relationships" do

    it "has no valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
    end

    it "has ImagingEvent as valid child concern" do
      expect(subject.valid_child_concerns).to match_array([])
    end

  end

  describe "instance" do
    subject { BiologicalSpecimen.create(title: ["BSO title"], vouchered: ["Yes"]) }

    describe "valid work relationships" do

      it "has no valid parents" do
        expect(subject.valid_parent_concerns).to match_array([])
      end

      it "has ImagingEvent as valid child concern" do
        expect(subject.valid_child_concerns).to match_array([])
      end

    end

    describe "taxonomy methods" do
      let (:taxonomy1)  { valkyrie_create(:taxonomy_resource, id: "1", title: ["taxonomy1 title"], trusted: ["Yes"])}
      let (:taxonomy2)  { valkyrie_create(:taxonomy_resource, id: "2", title: ["taxonomy2 title"], trusted: ["Yes"])}
      let (:taxonomy3)  { valkyrie_create(:taxonomy_resource, id: "3", title: ["taxonomy3 title"], trusted: ["No"])}
      let (:organization){ Organization.create(id: "4", title: ["organization title"]) }
      let (:parents) {[taxonomy1, taxonomy2, taxonomy3, organization]}

      before do
        subject.organization_id = [organization.id]
        subject.taxonomy_id = [taxonomy1.id.to_s, taxonomy2.id.to_s, taxonomy3.id.to_s]
        subject.canonical_taxonomy = [taxonomy1.id.to_s]
      end

      describe "#taxonomies" do
        it 'returns correct taxonomies' do
          expect(subject.taxonomies).to match_array([taxonomy1, taxonomy2, taxonomy3])
        end
      end

      describe "#taxonomies_titles" do
        it 'returns all its taxonomy titles' do
          expect(subject.taxonomies_titles).to match_array([taxonomy1.title.first, taxonomy2.title.first, taxonomy3.title.first])
        end
      end

      describe "#canonical_taxonomy_object" do
        it 'returns the Taxonomy for its canonical_taxonomy' do
          expect(subject.canonical_taxonomy_object).to eq(taxonomy1)
        end
      end

      describe "#canonical_taxonomy_title" do
        it 'returns the title for its canonical_taxonomy' do
          expect(subject.canonical_taxonomy_title).to eq(taxonomy1.title.first)
        end
      end

      describe "#other_taxonomies" do
        it 'returns all taxonomies except the canonical taxonomy' do
          expect(subject.other_taxonomies).to match_array([taxonomy2, taxonomy3])
        end
      end

      describe "#trusted_taxonomies" do
        it 'returns all organizational taxonomies except the canonical taxonomy' do
          expect(subject.trusted_taxonomies).to match_array([taxonomy2])
        end
      end

      describe "#user_taxonomies" do
        before do
          taxonomy1.trusted = ["No"]
        end
        it 'returns all taxonomies that are not trusted except the canonical taxonomy' do
          expect(subject.user_taxonomies).to match_array([taxonomy3])
        end
      end
    end
  end

  describe '#clear_previous_remote_ids' do
    let(:specimen) do
      described_class.new(idigbio_uuid: ['old-uuid'], idigbio_recordset_id: ['old-rs'],
                          gbif_occurrence_key: ['old-key'], gbif_dataset_key: ['old-ds'])
    end
    let(:params_for_update) { { biospec_model_params: { 'remote_source' => remote_source, 'catalog_number' => '1' } } }
    let(:remote_source) { 'gbif' }

    context 'when the occurrence ID changed to a GBIF record' do
      it 'clears the iDigBio IDs and keeps the GBIF ones for the record to replace' do
        allow(specimen).to receive(:occurrence_id_changed?).and_return(true)
        specimen.clear_previous_remote_ids(params_for_update)
        expect(params_for_update[:biospec_model_params]).to include('idigbio_uuid' => [], 'idigbio_recordset_id' => [], 'catalog_number' => '1')
        expect(params_for_update[:biospec_model_params]).not_to have_key('gbif_occurrence_key')
      end
    end

    context 'when the occurrence ID changed to an iDigBio record' do
      let(:remote_source) { 'idigbio' }

      it 'clears the GBIF IDs and keeps the iDigBio ones for the record to replace' do
        allow(specimen).to receive(:occurrence_id_changed?).and_return(true)
        specimen.clear_previous_remote_ids(params_for_update)
        expect(params_for_update[:biospec_model_params]).to include('gbif_occurrence_key' => [], 'gbif_dataset_key' => [])
        expect(params_for_update[:biospec_model_params]).not_to have_key('idigbio_uuid')
      end
    end

    it 'keeps every ID when the occurrence ID did not change' do
      allow(specimen).to receive(:occurrence_id_changed?).and_return(false)
      specimen.clear_previous_remote_ids(params_for_update)
      expect(params_for_update[:biospec_model_params].keys).to eq(['remote_source', 'catalog_number'])
    end
  end
end
