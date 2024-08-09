require 'rails_helper'
RSpec.describe UpdateSpecimensFromIdigbioJob do

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
