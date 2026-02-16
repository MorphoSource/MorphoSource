require 'rails_helper'
require 'hyrax/specs/spy_listener'

RSpec.describe Valkyrie::CharacterizationJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  let(:user) { FactoryBot.create(:user) }

  # Mock parent update service by default
  before do
    allow(Morphosource::Characterization::Valkyrie::FileSetCharacterizationParentUpdateService)
      .to receive(:run).and_return(true)
  end

  # Helper method to get file_metadata from file_set
  def get_file_metadata(file_set)
    Hyrax.custom_queries.find_original_file(file_set: file_set)
  end

  describe '#perform' do
    context 'non-archive deposits' do
      describe 'DICOM characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_dcm_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has DICOM attributes in the metadata" do
          expect(subject.mime_type).to eq("application/dicom")
          expect(subject.spacing_between_slices.first).to eq("0.0100088")
          expect(subject.modality.first).to eq("OT")
          expect(subject.secondary_capture_device_manufacturer.first).to eq("FEI")
          expect(subject.secondary_capture_device_software_vers.first).to eq("Avizo")
        end

        it "indexes to Solr" do
          solr_doc = SolrDocument.find(file_set.id)
          expect(solr_doc[:mime_type_ssi]).to eq("application/dicom")
        end
      end

      describe 'PLY characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_ply_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has PLY mesh attributes in the metadata" do
          expect(subject.point_count.first).to eq("35947")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.000001).of(0.120673)
          expect(subject.color_format&.first.present?).to be false
          expect(subject.normals_format&.first.present?).to be false
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("True")
          expect(subject.centroid_x.first.to_f).to be_within(0.000001).of(-0.016840)
          expect(subject.centroid_y.first.to_f).to be_within(0.000001).of(0.110154)
          expect(subject.centroid_z.first.to_f).to be_within(0.000001).of(-0.001537)
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
          expect(subject.gltf_inspect_version&.first.present?).to be false
        end

        it "indexes to Solr" do
          solr_doc = SolrDocument.find(file_set.id)
          expect(solr_doc[:point_count_tesim].first).to eq("35947")
        end
      end

      describe 'OBJ characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_obj_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has OBJ mesh attributes in the metadata" do
          expect(subject.point_count.first).to eq("35947")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("True")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end

      describe 'simple GLTF characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_gltf_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has GLTF attributes in the metadata" do
          expect(subject.point_count.first).to eq("34834")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.edges_per_face.first).to eq("3")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.00001).of(0.15570)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.00001).of(0.15433)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.00001).of(0.12067)
          expect(subject.normals_format.first).to eq("vertex normals")
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.gltf_inspect_version&.first.present?).to be true
        end
      end

      describe 'simple GLB characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_glb_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has GLB attributes in the metadata" do
          expect(subject.point_count.first).to eq("34834")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.edges_per_face.first).to eq("3")
          expect(subject.normals_format.first).to eq("vertex normals")
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.gltf_inspect_version&.first.present?).to be true
        end
      end

      describe 'complex GLB characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_glb_complex_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has GLB attributes in the metadata" do
          expect(subject.point_count.first).to eq("86317")
          expect(subject.face_count.first).to eq("149999")
          expect(subject.edges_per_face.first).to eq("3")
          expect(subject.normals_format.first).to eq("vertex normals")
          expect(subject.has_uv_space.first).to eq("True")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.gltf_inspect_version&.first.present?).to be true
        end
      end

      describe 'STL characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_stl_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has STL attributes in the metadata" do
          expect(subject.point_count.first).to eq("34834")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end

      describe 'WRL characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_wrl_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has WRL attributes in the metadata" do
          expect(subject.point_count.first).to eq("35947")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("True")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end

      describe 'X3D characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_x3d_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has X3D attributes in the metadata" do
          expect(subject.point_count.first).to eq("35947")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.bounding_box_y.first.to_f).to be_within(0.000001).of(0.154334)
          expect(subject.bounding_box_z.first.to_f).to be_within(0.000001).of(0.120674)
          expect(subject.has_uv_space.first).to eq("False")
          expect(subject.vertex_color.first).to eq("True")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end

      describe 'Invalid file characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_docx_file) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has no mesh attributes" do
          expect(subject.point_count).to eq([])
        end
      end
    end

    context 'archive deposits' do
      describe 'DICOM (ZIP) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_dcm_zip) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has DICOM archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type).to eq(["application/dicom"])
          expect(subject.contents_accepted_file_count).to eq([518])
          expect(JSON.parse(subject.contents_all_files&.first)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files&.first).length).to be > 0
          expect(subject.pixel_spacing.first).to eq("0.592047\\0.59091")
          expect(subject.modality.first).to eq("OT")
          expect(subject.secondary_capture_device_manufacturer.first).to eq("Thermo Fisher Scientific")
          expect(subject.secondary_capture_device_software_vers.first).to eq("Avizo")
        end
      end

      describe 'DICOM (TAR) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_dcm_tar) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has DICOM archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type).to eq(["application/dicom"])
          expect(subject.contents_accepted_file_count).to eq([518])
          expect(JSON.parse(subject.contents_all_files&.first)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files&.first).length).to be > 0
          expect(subject.pixel_spacing.first).to eq("0.592047\\0.59091")
        end
      end

      describe 'OBJ with textures (ZIP) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_obj_zip) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has OBJ archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type).to eq(["text/prs.wavefront-obj"])
          expect(subject.contents_accepted_file_count).to eq([4])
          expect(JSON.parse(subject.contents_all_files&.first)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files&.first).length).to be > 0
          expect(subject.point_count.first).to eq("75818")
          expect(subject.face_count.first).to eq("149999")
          expect(subject.has_uv_space.first).to eq("True")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.centroid_method.first.present?).to be true
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end

      describe 'OBJ with textures (TAR) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_obj_tar) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has OBJ archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type).to eq(["text/prs.wavefront-obj"])
          expect(subject.contents_accepted_file_count).to eq([4])
          expect(subject.point_count.first).to eq("75818")
          expect(subject.face_count.first).to eq("149999")
        end
      end

      describe 'GLTF (ZIP) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_gltf_zip) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has GLTF archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type).to eq(["model/gltf+json"])
          expect(subject.contents_accepted_file_count).to eq([4])
          expect(JSON.parse(subject.contents_all_files&.first)).to be_a(Array)
          expect(JSON.parse(subject.contents_all_files&.first).length).to be > 0
          expect(subject.point_count.first).to eq("86317")
          expect(subject.face_count.first).to eq("149999")
          expect(subject.edges_per_face.first).to eq("3")
          expect(subject.normals_format.first).to eq("vertex normals")
          expect(subject.has_uv_space.first).to eq("True")
          expect(subject.vertex_color.first).to eq("False")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.gltf_inspect_version&.first.present?).to be true
        end
      end

      describe 'GLTF (TAR) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_gltf_tar) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has GLTF archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/x-tar")
          expect(subject.contents_mime_type).to eq(["model/gltf+json"])
          expect(subject.contents_accepted_file_count).to eq([4])
          expect(subject.point_count.first).to eq("86317")
          expect(subject.face_count.first).to eq("149999")
        end
      end

      describe 'PLY (DEFLATE64 ZIP) characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_ply_deflate64_zip) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has PLY archive attributes in the metadata" do
          expect(subject.mime_type).to eq("application/zip")
          expect(subject.contents_mime_type).to eq(["application/ply"])
          expect(subject.point_count.first).to eq("35947")
          expect(subject.face_count.first).to eq("69451")
          expect(subject.bounding_box_x.first.to_f).to be_within(0.000001).of(0.155699)
          expect(subject.vertex_color.first).to eq("True")
          expect(subject.centroid_method.first).to eq("Bounding Box")
          expect(subject.blender_version&.first.present? ||
                 subject.pymeshlab_version&.first.present?).to be true
        end
      end
    end

    context 'event publishing' do
      let(:listener) { Hyrax::Specs::AppendingSpyListener.new }
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_ply_file) }
      let(:file_metadata) { get_file_metadata(file_set) }

      before { Hyrax.publisher.subscribe(listener) }
      after { Hyrax.publisher.unsubscribe(listener) }

      it "publishes file.characterized event" do
        described_class.perform_now(file_metadata.id.to_s)

        expect(listener.file_characterized.length).to eq(1)
        event = listener.file_characterized.first

        expect(event[:file_id]).to eq(file_metadata.id.to_s)
        expect(event[:file_set].id).to eq(file_set.id)
        expect(event[:path_hint]).to include('bunny.ply')
      end
    end

    context 'CRC32 job enqueueing' do
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_ply_file) }
      let(:file_metadata) { get_file_metadata(file_set) }

      it "enqueues CharacterizeCrc32Job with correct parameters" do
        expect {
          described_class.perform_now(file_metadata.id.to_s)
        }.to have_enqueued_job(Valkyrie::CharacterizeCrc32Job)
          .with(file_metadata.id.to_s)
      end
    end

    context 'parent update service' do
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_ply_file) }
      let(:file_metadata) { get_file_metadata(file_set) }

      it "calls parent update service twice (after FITS and after specialized)" do
        expect(Morphosource::Characterization::Valkyrie::FileSetCharacterizationParentUpdateService)
          .to receive(:run).with(kind_of(Hyrax::FileMetadata)).twice

        described_class.perform_now(file_metadata.id.to_s)
      end

      it "passes updated file_metadata to service" do
        call_count = 0
        expect(Morphosource::Characterization::Valkyrie::FileSetCharacterizationParentUpdateService)
          .to receive(:run) do |metadata|
            call_count += 1
            # point_count is only present after specialized (blender/pymeshlab) characterization
            expect(metadata.point_count).to be_present if call_count == 2
          end.twice

        described_class.perform_now(file_metadata.id.to_s)
      end
    end
  end
end