require 'rails_helper'
RSpec.describe UpdateSpecimensFromIdigbioJob do

  describe "idigbio_match_found" do
    let(:invalid_occurrence_id) { ["1234567"] }
    let(:occurrence_id) { ["urn:catalog:CM:VP:604"] }
    let(:empty_result) { {:status=>:success, :data=>[]} }
    let(:result) { {:status=>:success, :data=>[{"uuid"=>"068ad172-6c42-4fd6-b9d9-81c5c301bdf8"}]} }

    describe "validate occurrence_id" do
      before do 
        allow(subject).to receive(:idigbio_occurrence_id_results) { result }
      end
      it "invalid occurrence_id return -1" do
        expect(subject.idigbio_match_found(invalid_occurrence_id)).to eq(-1)
      end
      it "valid occurrence_id return count" do
        expect(subject.idigbio_match_found(occurrence_id)).to eq(1)
      end
    end

    describe "empty result" do
      before do 
        allow(subject).to receive(:idigbio_occurrence_id_results) { empty_result }
      end
      it "empty result return -1" do
        expect(subject.idigbio_match_found(occurrence_id)).to eq(-1)
      end
    end
  end

  describe "idigbio_recordset_different_from_org?" do
    let(:idb1) { { "indexTerms": {"recordset":"abc"} } }
    let(:idb2) { { "indexTerms": {"recordset":"xyz"} } }
    let(:org) { Organization.create({ title: ['test org'], recordset_id: ['abc'] }) }
    let(:bso) { BiologicalSpecimen.create(title: ["BSO title"], vouchered: ["Yes"], organization_id: [org.id]) }
    let(:bso_doc) { SolrDocument.find(bso.id) }

    describe "recordset is the same" do
      before do
        subject.instance_variable_set(:@idigbio_occurrence, idb1.deep_stringify_keys)
      end
      it "return false" do
        expect(subject.idigbio_recordset_different_from_org?(bso_doc)).to eq(false)
      end
    end

    describe "recordset is the different" do
      before do
        subject.instance_variable_set(:@idigbio_occurrence, idb2.deep_stringify_keys)
      end
      it "return true" do
        expect(subject.idigbio_recordset_different_from_org?(bso_doc)).to eq(true)
      end
    end
  end

end
