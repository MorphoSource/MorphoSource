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

  describe '#clear_previous_idigbio_ids' do
    let(:specimen) { described_class.new(idigbio_uuid: ['old-uuid'], idigbio_recordset_id: ['old-rs']) }
    let(:params_for_update) { { biospec_model_params: { 'remote_source' => remote_source, 'catalog_number' => '1' } } }
    let(:remote_source) { 'gbif' }

    it 'clears iDigBio IDs when the occurrence ID changed to a GBIF record' do
      allow(specimen).to receive(:occurrence_id_changed?).and_return(true)
      specimen.clear_previous_idigbio_ids(params_for_update)
      expect(params_for_update[:biospec_model_params]).to include('idigbio_uuid' => [], 'idigbio_recordset_id' => [], 'catalog_number' => '1')
    end

    it 'keeps them when the occurrence ID did not change' do
      allow(specimen).to receive(:occurrence_id_changed?).and_return(false)
      specimen.clear_previous_idigbio_ids(params_for_update)
      expect(params_for_update[:biospec_model_params]).not_to have_key('idigbio_uuid')
    end

    context 'when the new record is from iDigBio' do
      let(:remote_source) { 'idigbio' }

      it 'leaves the IDs for the record to replace' do
        allow(specimen).to receive(:occurrence_id_changed?).and_return(true)
        specimen.clear_previous_idigbio_ids(params_for_update)
        expect(params_for_update[:biospec_model_params]).not_to have_key('idigbio_uuid')
      end
    end
  end
end
