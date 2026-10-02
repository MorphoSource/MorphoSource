require 'rails_helper'

RSpec.describe CharacterizeJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    let(:file_set) { FactoryBot.create(:file_set) }

    context 'non-archive deposit' do
      describe 'DCM characterization' do
        let(:file_path_string) {fixture_path + '/CMB06020_R-m1_011.dcm'}
        let(:dcm_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, dcm_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
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
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has PLY attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("35947")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120673)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("True")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'OBJ characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.obj'}
        let(:mesh_file) { File.open(file_path_string) }
        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has OBJ attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("35947")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("True")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'simple GLTF characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.gltf'}
        let(:mesh_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has GLTF attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("34834")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:edges_per_face_tesim].first).to eq("3")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.00001).of(0.15570)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.00001).of(0.15433)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.00001).of(0.12067)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim].first).to eq("vertex normals")
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("False")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110155)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001535)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be false
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be true
        end
      end

      describe 'simple GLB characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.glb'}
        let(:mesh_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has GLB attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("34834")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:edges_per_face_tesim].first).to eq("3")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.00001).of(0.15570)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.00001).of(0.15433)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.00001).of(0.12067)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim].first).to eq("vertex normals")
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("False")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110155)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001535)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be false
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be true
        end
      end

      describe 'complex GLB characterization' do
        let(:file_path_string) {fixture_path + '/whale/whale-mpc-677-150k-4096.glb'}
        let(:mesh_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has GLB attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("86317")
          expect(subject[:face_count_tesim].first).to eq("149999")
          expect(subject[:edges_per_face_tesim].first).to eq("3")
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim].first).to eq("vertex normals")
          expect(subject[:has_uv_space_tesim].first).to eq("True")
          expect(subject[:vertex_color_tesim].first).to eq("False")

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be false
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be true
        end
      end

      describe 'STL characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.stl'}
        let(:mesh_file) { File.open(file_path_string) }
        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has STL attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("34834")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("False")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'WRL characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.wrl'}
        let(:mesh_file) { File.open(file_path_string) }
        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has WRL attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("35947")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("True")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'X3D characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny.x3d'}
        let(:mesh_file) { File.open(file_path_string) }
        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has X3D attributes in the metadata" do
          # mesh details
          expect(subject[:point_count_tesim].first).to eq("35947")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("True")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'Not a valid mesh file' do
        let(:file_path_string) {fixture_path + '/bunny/Source.docx'}
        let(:mesh_file) { File.open(file_path_string) }
        before do
          Hydra::Works::AddFileToFileSet.call(file_set, mesh_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end
        subject { SolrDocument.find(file_set.id) }
        it "has no mesh attributes" do
          expect(subject[:point_count_tesim]).to be_nil
          # todo: perhaps check for error message later
        end
      end
    end

    context 'archive deposits' do
      describe 'DCM (ZIP) characterization' do
        let(:file_path_string) {fixture_path + '/dcm_stack/dcm_stack.zip'}
        let(:dcm_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, dcm_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has dicom attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type.first).to eq("application/dicom")
          expect(subject.contents_accepted_file_count.first).to eq("518")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject.pixel_spacing.first).to eq("0.592047\\0.59091")
          expect(subject.modality.first).to eq("OT")
          expect(subject[:secondary_capture_device_manufacturer_tesim].first).to eq("Thermo Fisher Scientific")
          expect(subject[:secondary_capture_device_software_vers_tesim].first).to eq("Avizo")
        end
      end

      describe 'DCM (TAR) characterization' do
        let(:file_path_string) {fixture_path + '/dcm_stack/dcm_stack.tar'}
        let(:dcm_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, dcm_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has dicom attributes in the metadata" do
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type.first).to eq("application/dicom")
          expect(subject.contents_accepted_file_count.first).to eq("518")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject.pixel_spacing.first).to eq("0.592047\\0.59091")
          expect(subject.modality.first).to eq("OT")
          expect(subject[:secondary_capture_device_manufacturer_tesim].first).to eq("Thermo Fisher Scientific")
          expect(subject[:secondary_capture_device_software_vers_tesim].first).to eq("Avizo")
        end
      end

      describe 'OBJ with textures (ZIP) characterization' do
        let(:file_path_string) {fixture_path + '/whale/whale-mpc-677-150k-4096-obj.zip'}
        let(:zip_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, zip_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has OBJ attributes in the metadata" do
          # mesh details
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type.first).to eq("text/prs.wavefront-obj")
          expect(subject.contents_accepted_file_count.first).to eq("4")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject[:point_count_tesim].first).to eq("75818")
          expect(subject[:face_count_tesim].first).to eq("149999")
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("True")
          expect(subject[:vertex_color_tesim].first).to eq("False")

          # method and tool details
          expect(subject[:centroid_method_tesim].first.present?).to be true
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'OBJ with textures (TAR) characterization' do
        let(:file_path_string) {fixture_path + '/whale/whale-mpc-677-150k-4096-obj.tar'}
        let(:zip_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, zip_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has OBJ attributes in the metadata" do
          # mesh details
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type.first).to eq("text/prs.wavefront-obj")
          expect(subject.contents_accepted_file_count.first).to eq("4")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject[:point_count_tesim].first).to eq("75818")
          expect(subject[:face_count_tesim].first).to eq("149999")
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("True")
          expect(subject[:vertex_color_tesim].first).to eq("False")

          # method and tool details
          expect(subject[:centroid_method_tesim].first.present?).to be true
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end

      describe 'GLTF (ZIP) characterization' do
        let(:file_path_string) {fixture_path + '/whale/whale-mpc-677-150k-4096-gltf.zip'}
        let(:zip_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, zip_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has GLTF attributes in the metadata" do
          # mesh details
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type.first).to eq("model/gltf+json")
          expect(subject.contents_accepted_file_count.first).to eq("4")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject[:point_count_tesim].first).to eq("86317")
          expect(subject[:face_count_tesim].first).to eq("149999")
          expect(subject[:edges_per_face_tesim].first).to eq("3")
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim].first).to eq("vertex normals")
          expect(subject[:has_uv_space_tesim].first).to eq("True")
          expect(subject[:vertex_color_tesim].first).to eq("False")

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be false
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be true
        end
      end

      describe 'GLTF (TAR) characterization' do
        let(:file_path_string) {fixture_path + '/whale/whale-mpc-677-150k-4096-gltf.tar'}
        let(:zip_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, zip_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has GLTF attributes in the metadata" do
          # mesh details
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type.first).to eq("model/gltf+json")
          expect(subject.contents_accepted_file_count.first).to eq("4")
          expect(JSON.parse(subject.contents_all_files)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files).length).to be > 0
          expect(subject[:point_count_tesim].first).to eq("86317")
          expect(subject[:face_count_tesim].first).to eq("149999")
          expect(subject[:edges_per_face_tesim].first).to eq("3")
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim].first).to eq("vertex normals")
          expect(subject[:has_uv_space_tesim].first).to eq("True")
          expect(subject[:vertex_color_tesim].first).to eq("False")

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be false
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be true
        end
      end

      describe 'PLY (DEFLATE64 ZIP) characterization' do
        let(:file_path_string) {fixture_path + '/bunny/bunny_deflate64.zip'}
        let(:zip_file) { File.open(file_path_string) }

        before do
          Hydra::Works::AddFileToFileSet.call(file_set, zip_file, :original_file)
          described_class.perform_now(file_set, file_set.original_file.id, file_path_string)
        end

        # find the solr doc, then verify the metadata
        subject { SolrDocument.find(file_set.id) }

        it "has PLY attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type.first).to eq("application/ply")

          # mesh details
          expect(subject[:point_count_tesim].first).to eq("35947")
          expect(subject[:face_count_tesim].first).to eq("69451")
          expect(subject[:bounding_box_x_tesim].first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject[:bounding_box_y_tesim].first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject[:bounding_box_z_tesim].first.to_f).to be_within(0.000001).of(0.120673)
          expect(subject[:color_format_tesim]&.first.present?).to be false
          expect(subject[:normals_format_tesim]&.first.present?).to be false
          expect(subject[:has_uv_space_tesim].first).to eq("False")
          expect(subject[:vertex_color_tesim].first).to eq("True")
          expect(subject[:centroid_x_tesim].first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject[:centroid_y_tesim].first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject[:centroid_z_tesim].first.to_f).to be_within(0.000001).of(-0.001537)

          # method and tool details
          expect(subject[:centroid_method_tesim].first).to eq "Bounding Box"
          expect(subject[:blender_version_tesim]&.first.present? || subject[:pymeshlab_version_tesim]&.first.present?).to be true
          expect(subject[:gltf_inspect_version_tesim]&.first.present?).to be false
        end
      end
    end
  end
end