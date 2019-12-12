require 'iiif_manifest'
require 'rails_helper'

RSpec.describe Hyrax::MsFileSetPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability, request) }
  let(:attributes) { file.to_solr }
  let(:user) { double(user_key: 'sarah') }

  let(:request) { double(base_url: 'http://test.host') }
  let(:id) { '999' }
  let(:read_permission) { true }  
  let(:file_set) { FactoryBot.create(:file_set) }
  

  describe 'Dicom characterization' do
    let(:file_path_string) {fixture_path + '/CMB06020_R-m1_011.dcm'}
    let(:dcm_file) { File.open(file_path_string) }

    before do
      Hydra::Works::AddFileToFileSet.call(file_set, dcm_file, :original_file)
      # perform the characterization job ( app/jobs/characterize_job.rb )
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end

    # find the solr doc, then verify the metadata
    subject { SolrDocument.find(file_set.id) }

    it "has dicom attributes in the metadata" do
      expect(subject[:mime_type_ssi]).to eq("application/dicom")
      expect(subject[:spacing_between_slices_tesim].first).to eq("0.0100088")
      expect(subject[:modality_tesim].first).to eq("OT")
      expect(subject[:secondary_capture_device_manufacturer_tesim].first).to eq("FEI")
      expect(subject[:secondary_capture_device_software_vers_tesim].first).to eq("Avizo")
    end
      
  end

  describe 'PLY characterization' do
    let(:file_path_string) {fixture_path + '/bunny/bunny.ply'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has PLY attributes in the metadata" do
      expect(subject[:point_count_tesim].first).to eq("35947")
      expect(subject[:face_count_tesim].first).to eq("69451")
      expect(subject[:edges_per_face_tesim].first).to eq("3")
      expect(subject[:bounding_box_x_tesim].first).to eq("0.1556989997625351")
      expect(subject[:bounding_box_y_tesim].first).to eq("0.15433360636234283")
      expect(subject[:bounding_box_z_tesim].first).to eq("0.1206732988357544")
      expect(subject[:color_format_tesim].first).to eq("")
      expect(subject[:normals_format_tesim].first).to eq("")
      expect(subject[:has_uv_space_tesim].first).to eq("False")
      expect(subject[:vertex_color_tesim].first).to eq("False")
      expect(subject[:centroid_x_tesim].first).to eq("-0.026759909997859")
      expect(subject[:centroid_y_tesim].first).to eq("0.09521605980032478")
      expect(subject[:centroid_z_tesim].first).to eq("0.00894711457962819")
    end
  end

  describe 'OBJ characterization' do
    let(:file_path_string) {fixture_path + '/bunny/bunny.obj'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has OBJ attributes in the metadata" do
      expect(subject[:point_count_tesim].first).to eq("34834")
      expect(subject[:face_count_tesim].first).to eq("69451")
      expect(subject[:edges_per_face_tesim].first).to eq("3")
      expect(subject[:bounding_box_x_tesim].first).to eq("0.1556990034878254")
      expect(subject[:bounding_box_y_tesim].first).to eq("0.15433400869369507")
      expect(subject[:bounding_box_z_tesim].first).to eq("0.1206739991903305")
      expect(subject[:color_format_tesim].first).to eq("")
      expect(subject[:normals_format_tesim].first).to eq("")
      expect(subject[:has_uv_space_tesim].first).to eq("False")
      expect(subject[:vertex_color_tesim].first).to eq("False")
      expect(subject[:centroid_x_tesim].first).to eq("-0.026662636876096206")
      expect(subject[:centroid_y_tesim].first).to eq("0.09490209697499395")
      expect(subject[:centroid_z_tesim].first).to eq("0.008991039898314488")
    end
  end
    
  describe 'STL characterization' do
    let(:file_path_string) {fixture_path + '/bunny/bunny.stl'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has STL attributes in the metadata" do
      expect(subject[:point_count_tesim].first).to eq("34834")
      expect(subject[:face_count_tesim].first).to eq("69451")
      expect(subject[:edges_per_face_tesim].first).to eq("3")
      expect(subject[:bounding_box_x_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_y_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_z_tesim].first).to start_with("0.")
      expect(subject[:color_format_tesim].first).to eq("")
      expect(subject[:normals_format_tesim].first).to eq("")
      expect(subject[:has_uv_space_tesim].first).to eq("False")
      expect(subject[:vertex_color_tesim].first).to eq("False")
      expect(subject[:centroid_x_tesim].first).to start_with("-0.")
      expect(subject[:centroid_y_tesim].first).to start_with("0.")
      expect(subject[:centroid_z_tesim].first).to start_with("0.")
    end
  end

  describe 'WRL characterization' do
    let(:file_path_string) {fixture_path + '/bunny/bunny.wrl'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has WRL attributes in the metadata" do
      expect(subject[:point_count_tesim].first).to eq("35947")
      expect(subject[:face_count_tesim].first).to eq("69451")
      expect(subject[:edges_per_face_tesim].first).to eq("3")
      expect(subject[:bounding_box_x_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_y_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_z_tesim].first).to start_with("0.")
      expect(subject[:color_format_tesim].first).to eq("vertex color")
      expect(subject[:normals_format_tesim].first).to eq("")
      expect(subject[:has_uv_space_tesim].first).to eq("False")
      expect(subject[:vertex_color_tesim].first).to eq("True")
      expect(subject[:centroid_x_tesim].first).to start_with("-0.")
      expect(subject[:centroid_y_tesim].first).to start_with("0.")
      expect(subject[:centroid_z_tesim].first).to start_with("0.")
    end
  end

  describe 'X3D characterization' do
    let(:file_path_string) {fixture_path + '/bunny/bunny.x3d'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has X3D attributes in the metadata" do
      expect(subject[:point_count_tesim].first).to eq("34834")
      expect(subject[:face_count_tesim].first).to eq("69451")
      expect(subject[:edges_per_face_tesim].first).to eq("3")
      expect(subject[:bounding_box_x_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_y_tesim].first).to start_with("0.")
      expect(subject[:bounding_box_z_tesim].first).to start_with("0.")
      expect(subject[:color_format_tesim].first).to eq("vertex color")
      expect(subject[:normals_format_tesim].first).to eq("")
      expect(subject[:has_uv_space_tesim].first).to eq("False")
      expect(subject[:vertex_color_tesim].first).to eq("True")
      expect(subject[:centroid_x_tesim].first).to start_with("-0.")
      expect(subject[:centroid_y_tesim].first).to start_with("0.")
      expect(subject[:centroid_z_tesim].first).to start_with("0.")
    end
  end

  describe 'Not a valid mesh file' do
    let(:file_path_string) {fixture_path + '/bunny/Source.docx'}
    let(:mesh_file) { File.open(file_path_string) }
    before do
      Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
      CharacterizeJob.perform_now(file_set, file_set.original_file.id, file_path_string)
    end
    subject { SolrDocument.find(file_set.id) }
    it "has no mesh attributes" do
      expect(subject[:point_count_tesim]).to be_nil
      # todo: perhaps check for error message later
    end
  end

end