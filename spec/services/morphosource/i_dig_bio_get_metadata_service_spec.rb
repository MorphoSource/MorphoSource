require 'rails_helper'

RSpec.describe Morphosource::IDigBioGetMetadataService do

  let!(:org) { Organization.create({ title: ['test org'], recordset_id: ['abc'] }) }
  let!(:specimen) { 
    BiologicalSpecimen.create(
      title: ["title"], 
      vouchered: ["Yes"], 
      organization_id: [org.id],
      idigbio_recordset_id: ["recordset_id_1"]
    ) }

  subject { described_class.new(specimen.id) }

  describe "#occurrence_id_valid?" do
    let (:invalid_oid) { ['1234567'] }
    let (:invalid_oid_2) { ['12345678'] }
    let (:invalid_oid_3) { ['abcdefgh'] }
    let (:valid_oid) { ['abcdefg7'] }

    describe "less than 8 chars" do
      before do
        subject.instance_variable_set(:@occurrence_id, invalid_oid)
      end      
      it "occurrence_id invalid" do
        expect(subject.occurrence_id_valid?).to eq(false)
      end
    end

    describe "no alphabet" do
      before do
        subject.instance_variable_set(:@occurrence_id, invalid_oid_2)
      end      
      it "occurrence_id invalid" do
        expect(subject.occurrence_id_valid?).to eq(false)
      end
    end

    describe "no digit" do
      before do
        subject.instance_variable_set(:@occurrence_id, invalid_oid_3)
      end      
      it "occurrence_id invalid" do
        expect(subject.occurrence_id_valid?).to eq(false)
      end
    end

    describe "valid id" do
      before do
        subject.instance_variable_set(:@occurrence_id, valid_oid)
      end      
      it "occurrence_id valid" do
        expect(subject.occurrence_id_valid?).to eq(true)
      end
    end

  end

  describe "#idigbio_recordset_different_from_org?" do
    
    let(:idb_result1) {
      {
        :status=>:success,
        :data=>[{
          "indexTerms" => {
            "recordset" => "abc"
          }
        }]
      }
    }
    let(:idb_result2) {
      {
        :status=>:success,
        :data=>[{
          "indexTerms" => {
            "recordset" => "xyz"
          }
        }]
      }
    }

    describe "recordset is the same" do
      before do
        subject.instance_variable_set(:@occurrence_id_results, idb_result1)
      end
      it "return false" do
        expect(subject.idigbio_recordset_different_from_org?).to eq(false)
      end
    end

    describe "recordset is the different" do
      before do
        subject.instance_variable_set(:@occurrence_id_results, idb_result2)
      end
      it "return true" do
        expect(subject.idigbio_recordset_different_from_org?).to eq(true)
      end
    end
  end

end
