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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'CMB06020_R-m1_011.dcm') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.ply') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.obj') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.gltf') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.glb') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'whale/whale-mpc-677-150k-4096.glb') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.stl') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.wrl') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.x3d') }
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

      describe 'JPEG image characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'images/ms.jpg') }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has image attributes in the metadata" do
          expect(subject.mime_type).to eq("image/jpeg")
          expect(subject.height.first).to eq("360")
          expect(subject.width.first).to eq("360")
        end
      end

      describe 'Invalid file characterization' do
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/Source.docx') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'dcm_stack/dcm_stack.zip') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'dcm_stack/dcm_stack.tar') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'whale/whale-mpc-677-150k-4096-obj.zip') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'whale/whale-mpc-677-150k-4096-obj.tar') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'whale/whale-mpc-677-150k-4096-gltf.zip') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'whale/whale-mpc-677-150k-4096-gltf.tar') }
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
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny_deflate64.zip') }
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
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.ply') }
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
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.ply') }
      let(:file_metadata) { get_file_metadata(file_set) }

      it "enqueues CharacterizeCrc32Job with correct parameters" do
        expect {
          described_class.perform_now(file_metadata.id.to_s)
        }.to have_enqueued_job(Valkyrie::CharacterizeCrc32Job)
          .with(file_metadata.id.to_s)
      end
    end

    context 'parent update service' do
      let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file, fixture_path: 'bunny/bunny.ply') }
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

    context 'external URL file' do
      let(:working_external_path) { Rails.root.join('tmp', 'test_external_cache') }

      before do
        FileUtils.mkdir_p(working_external_path)
        allow(Hyrax.config).to receive(:working_external_path).and_return(working_external_path.to_s)
      end

      after do
        FileUtils.rm_rf(working_external_path)
      end

      describe 'external JPEG image characterization' do
        let(:remote_url) { 'https://remote.example.com/files/ms.jpg' }
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_external_file, remote_url: remote_url) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          stub_request(:get, remote_url)
            .to_return(body: File.binread(Rails.root.join('spec', 'fixtures', 'images', 'ms.jpg')), status: 200)
          described_class.perform_now(file_metadata.id.to_s)
        end

        subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

        it "has image attributes in the metadata" do
          expect(subject.mime_type).to eq("image/jpeg")
          expect(subject.height.first).to eq("360")
          expect(subject.width.first).to eq("360")
        end

        it "preserves the external URL as file_identifier" do
          expect(subject.file_identifier.to_s).to eq(remote_url)
        end
      end

      describe 'external GLB characterization' do
        let(:remote_url) { 'https://remote.example.com/files/whale-mpc-677-150k-4096.glb' }
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_external_file, remote_url: remote_url) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          stub_request(:get, remote_url)
            .to_return(body: File.binread(Rails.root.join('spec', 'fixtures', 'whale', 'whale-mpc-677-150k-4096.glb')), status: 200)
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

        it "preserves the external URL as file_identifier" do
          expect(subject.file_identifier.to_s).to eq(remote_url)
        end
      end

      describe 'external DICOM (ZIP) characterization' do
        let(:remote_url) { 'https://remote.example.com/files/dcm_stack.zip' }
        let(:file_set) { FactoryBot.valkyrie_create(:valkyrie_file_set, :with_external_file, remote_url: remote_url) }
        let(:file_metadata) { get_file_metadata(file_set) }

        before do
          stub_request(:get, remote_url)
            .to_return(body: File.binread(Rails.root.join('spec', 'fixtures', 'dcm_stack', 'dcm_stack.zip')), status: 200)
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

        it "preserves the external URL as file_identifier" do
          expect(subject.file_identifier.to_s).to eq(remote_url)
        end
      end
    end
  end
end
