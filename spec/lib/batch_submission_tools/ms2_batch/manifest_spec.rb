require 'rails_helper'

RSpec.describe BatchSubmissionTools::Ms2Batch::Manifest do

  let(:admin_user)             { User.create(email: 'email@email.com', password: 'password', sftp_share: '/tmp') }
  let(:depositor)              { User.create(email: 'email2@email.com', password: 'password', sftp_share: '') }
  let(:admins)                 { Role.create(name: 'admin') }
  let(:contributors)   		   { Role.create(name: 'contributor') }

	let (:input_path) { fixture_path + '/batch_submission_manifest_object_test.xlsx'}
  let (:media_path) { fixture_path }
  let(:device)                { Device.create(title: ['device'], modality: ['Photogrammetry'])}
  let(:organization)  { Organization.create(title: ['Organization'] ) }
  let(:media_ownership_fields) {
         {"visibility"=>"restricted", "download_reviewer"=>["e1eefa"], "rights_holder"=>["org ip holder"], "rights_statement"=>"http://rightsstatements.org/vocab/InC-OW-EU/1.0/", "license"=>["https://creativecommons.org/licenses/by-sa/4.0/"], "morphosource_use_agreement_type"=>"Permissive", "permits_commercial_use"=>"CommercialUsePermitted", "permits_3d_use"=>"3DPrintingPermitted", "required_archival_of_published_derivatives"=>"EncouragedButNotRequired", "funding"=>[""], "publisher"=>[""], "cite_as"=>"", "preview_mode"=>"Thumbnail Only", "agreement_uri"=>"", "member_of_collection_ids"=>""}
    }

  before do
    admins.users << [admin_user]
    contributors.users << [depositor]
    admins.save
    contributors.save
  end

  describe "Manifest object" do
    subject { BatchSubmissionTools::Ms2Batch::Manifest.new(
      input_path:input_path, 
      media_path:media_path, 
      admin_user:admin_user, 
      depositor:depositor, 
      organization_id:organization.id, 
      device_id:device.id,
      media_ownership_fields:media_ownership_fields
      )
    }

    it "contains rows data" do
      expect(subject.instance_variable_get(:@rows).count).to eql(3)
      expect(subject.instance_variable_get(:@rows).first.count).to eq(5)
    end

    it "contains biological_specimen_ingests and rows_to_bso data" do
      expect(subject.instance_variable_get(:@biological_specimen_ingests).count).to eq(2)
      expect(subject.instance_variable_get(:@biological_specimen_ingests).first.to_h[:attrs]).to include(
        "idigbio_uuid"=>"92cb764f-9c2b-485e-adec-4d19e81c520f",
         "description"=>"Imported from iDigBio. UUID: 92cb764f-9c2b-485e-adec-4d19e81c520f Occurrence ID: urn:uuid:21f5b097-ffb7-4821-9a79-deb3656d8b28",
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
         :organization_id=>["000200000"]
      )
      expect(subject.instance_variable_get(:@rows_to_bso)).to eq({0=>0, 1=>1, 2=>1})
    end

    it "contains taxonomy_ingests and rows_to_taxonomy data" do
      expect(subject.instance_variable_get(:@taxonomy_ingests).count).to eq(4)
      expect(subject.instance_variable_get(:@rows_to_taxonomy)).to eq({0=>[0, 1], 1=>[2], 2=>[3]})
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

  end

end