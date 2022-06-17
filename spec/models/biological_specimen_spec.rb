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

    describe "occurrence_id_valid" do
      let (:invalid_oid) { ['1234567'] }
      let (:invalid_oid_2) { ['12345678'] }
      let (:invalid_oid_3) { ['abcdefgh'] }
      let (:valid_oid) { ['abcdefg7'] }

      describe "less than 8 chars" do
        before do
          subject.occurrence_id = invalid_oid
        end      
        it "occurrence_id invalid" do
          expect(subject.occurrence_id_valid?).to eq(false)
        end
      end

      describe "no alphabet" do
        before do
          subject.occurrence_id = invalid_oid_2
        end      
        it "occurrence_id invalid" do
          expect(subject.occurrence_id_valid?).to eq(false)
        end
      end

      describe "no digit" do
        before do
          subject.occurrence_id = invalid_oid_3
        end      
        it "occurrence_id invalid" do
          expect(subject.occurrence_id_valid?).to eq(false)
        end
      end

      describe "valid id" do
        before do
          subject.occurrence_id = valid_oid
        end      
        it "occurrence_id valid" do
          expect(subject.occurrence_id_valid?).to eq(true)
        end
      end

    end

    describe "taxonomy methods" do
      let (:taxonomy1)  { Taxonomy.create(id: "1", title: ["taxonomy1 title"], trusted: ["Yes"]) }
      let (:taxonomy2)  { Taxonomy.create(id: "2", title: ["taxonomy2 title"], trusted: ["Yes"]) }
      let (:taxonomy3)  { Taxonomy.create(id: "3", title: ["taxonomy3 title"], trusted: ["No"]) }
      let (:organization){ Organization.create(id: "4", title: ["organization title"]) }
      let (:parents) {[taxonomy1, taxonomy2, taxonomy3, organization]}

      before do
        subject.organization_id = [organization.id]
        subject.taxonomy_id = [taxonomy1.id, taxonomy2.id, taxonomy3.id]
        subject.canonical_taxonomy = [taxonomy1.id]
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
end
