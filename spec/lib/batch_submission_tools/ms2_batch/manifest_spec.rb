require 'rails_helper'

RSpec.describe BatchSubmissionTools::Ms2Batch::Manifest do

  let(:admin_user)              { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:depositor)               { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:admins)                  { Role.create(name: 'admin') }
  let(:contributors)   		      { Role.create(name: 'contributor') }
  let(:input_path)              { fixture_path + '/batch_submission_manifest_object_test.xlsx'}
  let(:media_path)              { fixture_path }
  let(:device)                  { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry'])}
  let(:organization)            { Organization.create(title: ['Organization'] ) }
  let(:owner)                   { FactoryBot.create(:organization_collection, depositor: depositor.ms_id).id }
  let(:media_ownership_fields)  { { "visibility"=>"restricted",
                                    "download_reviewer"=>["e1eefa"],
                                    "rights_holder"=>["org ip holder"],
                                    "rights_statement"=>"http://rightsstatements.org/vocab/InC-OW-EU/1.0/",
                                    "license"=>["https://creativecommons.org/licenses/by-sa/4.0/"],
                                    "morphosource_use_agreement_type"=>"Permissive",
                                    "permits_commercial_use"=>"CommercialUsePermitted",
                                    "permits_3d_use"=>"3DPrintingPermitted",
                                    "required_archival_of_published_derivatives"=>"EncouragedButNotRequired",
                                    "funding"=>[""],
                                    "publisher"=>[""],
                                    "cite_as"=>"",
                                    "preview_mode"=>"Thumbnail Only",
                                    "agreement_uri"=>"",
                                    "member_of_collection_ids"=>"" } }
  let(:modality)                { 'Photogrammetry' }
  let(:base_args) do
    {
      media_path: media_path,
      admin_user: admin_user,
      depositor: depositor,
      owner: owner,
      organization_id: organization.id,
      device_id: device.id.to_s,
      media_ownership_fields: media_ownership_fields,
      modality: modality
    }
  end

  before do
    admins.users << [admin_user]
    contributors.users << [depositor]
    admins.save
    contributors.save
  end

  describe "Manifest object" do
    subject(:manifest) { BatchSubmissionTools::Ms2Batch::Manifest.new(**base_args.merge(input_path: input_path)) }

    it 'responds to owner' do
      expect(subject).to respond_to(:owner)
    end

    it "contains rows data" do
      expect(subject.instance_variable_get(:@rows).count).to eql(3)
      expect(subject.instance_variable_get(:@rows).first.count).to eq(5)
    end

    it "contains summary" do
      summary = subject.instance_variable_get(:@summary)
      expect(summary["depositor_id"]).to eq(depositor.ms_id)
      expect(summary["owner_id"]).to eq(owner)
      # media files come from the test manifest xlsx
      expect(summary["media_files"]).to eq(
        ["ANSP_Fish_181150.zip", "ANSP_Fish_180334_Head.jpg", "ANSP_Fish_181150.zip"])
    end

    it "contains biological_specimen_ingests and rows_to_bso data" do
      expect(subject.instance_variable_get(:@biological_specimen_ingests).count).to eq(2)
      expect(subject.instance_variable_get(:@biological_specimen_ingests).first.to_h[:attrs]).to include(
        "idigbio_uuid"=>"92cb764f-9c2b-485e-adec-4d19e81c520f",
        "idigbio_recordset_id"=>"0220907a-0463-4ae0-8a0b-77f5e80fff40",
        "vouchered"=>"Yes",
        "institution_code"=>"YPM",
        "collection_code"=>"VP",
        "catalog_number"=>"YPM VP 033191",
        "occurrence_id"=>"urn:uuid:21f5b097-ffb7-4821-9a79-deb3656d8b28",
        "related_url"=>["http://collections.peabody.yale.edu/search/Record/YPM-VP-033191"],
        "creator"=>["Louis S. Leakey, Mary D. Leakey"],
        "periodic_time"=>["Lower Pleistocene"],
        "original_location"=>"Tanzania",
        :organization_id=>[organization.id]
      )
      expect(subject.instance_variable_get(:@rows_to_bso)).to eq({0=>0, 1=>1, 2=>1})
    end

    it "contains taxonomy_ingests and rows_to_taxonomy data" do
      expect(subject.instance_variable_get(:@taxonomy_ingests).count).to be > 0
      expect(subject.instance_variable_get(:@rows_to_taxonomy).count).to be > 0
    end

    it "contains media_ie_pe_ingests data" do
      ingest_obj = subject.instance_variable_get(:@media_ie_pe_ingests)
      expect(ingest_obj.count).to eq(2)
      expect(ingest_obj.first.to_h[:imaging_event].count).to eq(1)
      expect(ingest_obj.first.to_h[:imaging_event][0][:initial_attrs]).to include(
        :description=>["smc IE desc"],
        :creator=>["John Doe"],
        :software=>["smc IE software"]
      )
      expect(ingest_obj.first.to_h[:children][1][:pe][:attrs]).to include(
        :software=>["pe smc sw"],
        :description=>["pe smc desc"]
      )
    end

    it "uses existing parent media specimen when specimen columns are blank" do
      parent_media_ms_id = '000001234'
      parent_specimen_id = '000009876'

      input_data = [
        {
          media: {
            media_file: ['ANSP_Fish_181150.zip'],
            raw_or_derived: ['Derived'],
            parent_ms_id: [parent_media_ms_id]
          },
          biological_specimen: {
            ms_id: [],
            occurrence_id: [],
            institution_code: [],
            collection_code: [],
            catalog_number: []
          },
          imaging_event: {},
          processing_event: {},
          taxonomy: {}
        }
      ]

      allow(Dir).to receive(:exist?).and_wrap_original do |original_method, path|
        path.present? ? original_method.call(path) : false
      end

      allow(SolrDocument).to receive(:find).with(parent_media_ms_id).and_return(
        'physical_object_id_ssim' => [parent_specimen_id]
      )

      manifest = BatchSubmissionTools::Ms2Batch::Manifest.new(
        **base_args.merge(input_data: input_data)
      )

      expect(manifest.instance_variable_get(:@biological_specimen_ingests).count).to eq(1)
      expect(manifest.instance_variable_get(:@biological_specimen_ingests).first.to_h[:id]).to eq(parent_specimen_id)
      expect(manifest.instance_variable_get(:@rows_to_bso)).to eq({ 0 => 0 })
    end

    context "with input_data" do
      let(:input_data) do
        parser = ::Morphosource::Ms2Batch::XLSXParser.new(input_path, false, false)
        parser.map { |row| row }
      end

      it "parses provided rows without reading a file path" do
        manifest_from_data = BatchSubmissionTools::Ms2Batch::Manifest.new(**base_args.merge(input_data: input_data))

        expect(manifest_from_data.instance_variable_get(:@rows).count).to eql(3)
        expect(manifest_from_data.instance_variable_get(:@skipped_row_count)).to eq(0)
        expect(manifest_from_data.instance_variable_get(:@summary)["manifest_tmp_file"]).to be_nil
      end

      it "removes newline characters from parsed field values" do
        dirty_input_data = input_data.deep_dup
        dirty_input_data.first[:"biological_specimen.ms_id"] = ["\n000200530\r\n"]
        dirty_input_data.first[:"media.identifier"] = ["id\nwith\rlinebreaks"]

        manifest_from_data = BatchSubmissionTools::Ms2Batch::Manifest.new(**base_args.merge(input_data: dirty_input_data))
        first_row = manifest_from_data.instance_variable_get(:@rows).first

        expect(first_row.dig(:biological_specimen, :ms_id)).to eq(["000200530"])
        expect(first_row.dig(:media, :identifier)).to eq(["id with linebreaks"])
      end
    end
  end
end
