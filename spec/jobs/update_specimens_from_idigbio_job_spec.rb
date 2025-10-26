require 'rails_helper'
RSpec.describe UpdateSpecimensFromIdigbioJob do

  let!(:org) { Organization.create({ title: ['test org'], recordset_id: ['abc'] }) }
  let!(:taxonomy) { valkyrie_create(:taxonomy_resource, title: ['test']) }
  let!(:bso) {
    BiologicalSpecimen.create(
      title: ["BSO title"],
      vouchered: ["Yes"],
      organization_id: [org.id],
      occurrence_id: ["occurrence_1"],
      canonical_taxonomy: ["taxonomy_1"],
      taxonomy_id: [taxonomy.id],
      idigbio_uuid: ["uuid_1"],
      idigbio_recordset_id: ["recordset_id_1"],
      vouchered: ["true"],
      institution_code: ["institution_1"],
      collection_code: ["collection_1"],
      catalog_number: ["catalog_1"],
      related_url: ["http://example.com"],
      creator: ["creator_1"],
      periodic_time: ["time_1"],
      original_location: ["location_1"]
    ) }

  describe "#specimen_result" do
    it 'returns a result containing the expected solr fields' do
      result = subject.specimen_result.first
      expect(result["id"]).not_to eq(nil)
      expect(result["organization_id_tesim"]).to eq([org.id])
      expect(result["occurrence_id_tesim"]).to eq(["occurrence_1"])
      expect(result["canonical_taxonomy_tesim"]).to eq(["taxonomy_1"])
      expect(result["taxonomy_id_tesim"]).to eq([taxonomy.id])
      expect(result["idigbio_uuid_tesim"]).to eq(["uuid_1"])
      expect(result["idigbio_recordset_id_tesim"]).to eq(["recordset_id_1"])
      expect(result["vouchered_tesim"]).to eq(["true"])
      expect(result["institution_code_tesim"]).to eq(["institution_1"])
      expect(result["collection_code_tesim"]).to eq(["collection_1"])
      expect(result["catalog_number_tesim"]).to eq(["catalog_1"])
      expect(result["related_url_tesim"]).to eq(["http://example.com"])
      expect(result["creator_tesim"]).to eq(["creator_1"])
      expect(result["periodic_time_tesim"]).to eq(["time_1"])
      expect(result["original_location_tesim"]).to eq(["location_1"])
    end
  end

end
