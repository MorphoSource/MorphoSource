# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Hyrax::MediaPresenter do
  # Presenter ability and request
  let(:ability) { Ability.new(User.new) }
  let(:request) { double(host: 'morphosource.org', base_url: 'https://www.morphosource.org') }

  # Solr documents necessary for presenter load
  let!(:media_document) { create(:media_document) }
  let!(:biological_specimen_document) { create(:biological_specimen_document) }
  let!(:imaging_event_document) { create(:imaging_event_document) }
  let!(:device_document) { create(:device_document) }

  let(:file_set_document) { create(:file_set_document) }
  let(:representative_presenter) { Hyrax::MediaFileSetPresenter.new(file_set_document, ability, request) }

  let(:subject) { described_class.new(media_document, ability, request) }

  describe "document attributes" do
    context "for media" do
      attributes = [
        :access_control_id, :agreement_uri, :ark, :cite_as, :depositor, :description, :doi,
        :download_reviewers, :fileset_accessibility, :fileset_visibility, :funding, :id, :identifier,
        :imaging_event_id, :is_remote_backed, :map_type, :media_organization_id, :media_type,
        :morphosource_use_agreement_type, :number_of_images_in_set, :organization_transfer_on_publish,
        :pending_org_transfer, :orientation, :part, :permits_3d_use, :permits_commercial_use, :physical_object_id,
        :physical_object_type, :preview_mode, :publication_status_label, :related_url,
        :remote_manifest_url, :remote_origin_url, :required_archival_of_published_derivatives,
        :rights_holder, :scale_bar, :series_type, :short_description, :side, :slice_thickness,
        :taxonomies_titles, :unit, :user_with_ownership, :x_spacing, :y_spacing, :z_spacing
      ]

      attributes.each do |attribute|
        it "returns false or a truthy value for media document attribute #{attribute}" do
          expect(subject.send(attribute)).to eq(false).or be_present
        end
      end

      it "returns an aup_path" do
        expect(subject.aup_path).to eq("ms_usage_std_comm_no_rearc_ms_3d_limited.pdf")
      end

      it "returns a media_permissions_string" do
        expect(subject.media_permissions_string).to eq("std_comm_no_rearc_ms_3d_limited")
      end

      it "returns not published for private media" do
        expect(subject.is_published?).to eq(false)
      end

      it "returns is published for published media" do
        allow(media_document).to receive(:fileset_accessibility).and_return(["open"])
        expect(subject.is_published?).to eq(true)
      end

      it "returns true on preview_in_3D if enabled" do
        expect(subject.preview_in_3D?).to eq(true)
      end

      it "returns false on preview_in_3D if disabled" do
        allow(media_document).to receive(:preview_mode).and_return(["Thumbnail Only"])
        expect(subject.preview_in_3D?).to eq(false)
      end
    end

    context "for biological specimen object" do
      attributes = [
        :catalog_number, :cho_type, :collection_code, :idigbio_uuid, :institution_code,
        :material, :occurrence_id, :vouchered
      ]

      attributes.each do |attribute|
        it "returns false or a truthy value for biological specimen document attribute #{attribute}" do
          expect(subject.send(attribute)).to eq(false).or be_present
        end
      end

      prefixed_attributes = [:title]

      prefixed_attributes.each do |attribute|
        it "returns false or a truthy value for biological specimen document attribute physical_object_#{attribute}" do
          expect(subject.send("physical_object_#{attribute}")).to eq(false).or be_present
        end
      end

      it "returns a source of record label for iDigBio-supplied records" do
        expect(subject.source_of_record).to eq("iDigBio")
      end

      it "returns correct URL link to the physical object" do
        expect(subject.physical_object_link).to eq("/concern/biological_specimens/#{biological_specimen_document.id}")
      end
    end

    context "for imaging event" do
      attributes = [
        :acquisition_type, :amperage, :background_removal, :detector_configuration,
        :detector_pixels_x, :detector_pixels_y, :detector_pixel_size_x, :detector_pixel_size_y,
        :detector_type, :exposure_time, :flux_normalization, :focal_length_type, :frame_averaging,
        :ie_filter, :ie_modality, :lens_make, :lens_model, :light_source, :optical_magnification,
        :phase_contrast, :pixel_spacing_calibration, :power, :projections, :rotation_number,
        :shading_correction, :slide_type, :source_detector_distance, :source_object_distance,
        :surrounding_material, :voltage, :xray_tube_type, :target_material, :target_type
      ]

      attributes.each do |attribute|
        it "returns false or a truthy value for imaging event document attribute #{attribute}" do
          expect(subject.send(attribute)).to eq(false).or be_present
        end
      end

      prefixed_attributes = [
        :creator, :date_created, :software, :description
      ]

      prefixed_attributes.each do |attribute|
        it "returns false or a truthy value for imaging event document attribute imaging_event_#{attribute}" do
          expect(subject.send("imaging_event_#{attribute}")).to eq(false).or be_present
        end
      end

      it "returns a human-readable modality label" do
        expect(subject.imaging_event_modality).to eq("X-Ray Computed Tomography (CT/microCT)")
      end

      it "returns a human-readable lens label" do
        expect(subject.lens).to eq("Canon X10")
      end

      it "returns a human-readable other details photogrammetry/photography label" do
        expect(subject.other_details).to eq("Fixed focal length / Sun light / Yes")
      end
    end

    context "for device" do
      attributes = [
        :device_organization_title, :device_organization_institution_name
      ]

      attributes.each do |attribute|
        it "returns false or a truthy value for device document attribute #{attribute}" do
          expect(subject.send(attribute)).to eq(false).or be_present
        end
      end

      prefixed_attributes = [
        :creator, :description, :id, :modality, :title
      ]

      prefixed_attributes.each do |attribute|
        it "returns false or a truthy value for device document attribute device_#{attribute}" do
          expect(subject.send("device_#{attribute}")).to eq(false).or be_present
        end
      end

      it "returns a human-readable device and facilty label" do
        expect(subject.device_and_facility).to include("Scanning Device Make Scanning Device Model")
        expect(subject.device_and_facility).to include("Collection Name (Institution Name)")
      end

      it "returns a human-readable device label" do
        expect(subject.device_label).to eq("Scanning Device Make Scanning Device Model")
      end

      it "returns a human-readable device modality labels" do
        expect(subject.device_modality_labels).to eq("X-Ray Computed Tomography (CT/microCT)")
      end

      it "returns a human-readable organization and institution label" do
        expect(subject.device_organization_institution).to eq("Collection Name (Institution Name)")
      end
    end

    context "for fileset" do
      before do
        allow(subject).to receive(:representative_presenter).and_return(representative_presenter)
      end

      attributes = [
        :bits_allocated, :bits_per_sample, :bounding_box_x, :bounding_box_y, :bounding_box_z,
        :centroid_x, :centroid_y, :centroid_z, :columns, :contents_accepted_file_count, :color_format,
        :color_space, :compression, :face_count, :has_uv_space, :height, :normals_format,
        :original_file_id, :point_count, :rows, :vertex_color, :width
      ]

      attributes.each do |attribute|
        it "returns false or a truthy value for fileset document attribute #{attribute}" do
          expect(subject.send(attribute)).to eq(false).or be_present
        end
      end

      it "returns a human-readable bounding box label" do
        expect(subject.bounding_box_dimensions).to eq("0.100, 0.100, 0.100")
      end

      it "returns a human-readable centroid location label" do
        expect(subject.centroid_location).to eq("0.500, 0.500, 0.500")
      end

      it "returns a human-readable file size label" do
        expect(subject.file_size).to eq("118 MB")
      end

      it "returns a human-readable acceptable file contents count label" do
        expect(subject.accepted_file_count).to eq("1,600")
      end

      ### Different behavior depending on if FileSet is single image or DCM in ZIP ###

      context "with single image file" do
        before do
          new_file_set_document = file_set_document.to_h
          new_file_set_document["mime_type_ssi"] = "image/jpeg"
          image_representative_presenter = Hyrax::MediaFileSetPresenter.new(SolrDocument.new(new_file_set_document), ability, request)
          allow(subject).to receive(:representative_presenter).and_return(image_representative_presenter)
        end

        it "returns image mime type" do
          expect(subject.mime_type).to eq("image/jpeg")
        end

        it "returns correct image height" do
          expect(subject.image_height).to eq("900")
        end

        it "returns correct image width" do
          expect(subject.image_width).to eq("1800")
        end

        it "returns correct color depth" do
          expect(subject.color_depth).to eq("32")
        end
      end

      context "with dicom file within zip" do
        before do
          new_file_set_document = file_set_document.to_h
          new_file_set_document["mime_type_ssi"] = "application_zip"
          new_file_set_document["contents_mime_type_tesim"] = ["application/dicom"]
          image_representative_presenter = Hyrax::MediaFileSetPresenter.new(SolrDocument.new(new_file_set_document), ability, request)
          allow(subject).to receive(:representative_presenter).and_return(image_representative_presenter)
        end

        it "returns image mime type" do
          expect(subject.mime_type).to eq("application/dicom")
        end

        it "returns correct image height" do
          expect(subject.image_height).to eq("600")
        end

        it "returns correct image width" do
          expect(subject.image_width).to eq("1200")
        end

        it "returns correct color depth" do
          expect(subject.color_depth).to eq("16")
        end
      end

      ### Different behavior whether file is local or remote in origin ###

      context "with local file" do
        it "returns nothing for file origin" do
          expect(subject.file_origin).to eq("")
        end

        it "returns original file ready" do
          expect(subject.file_set_original_file_ready).to eq(true)
        end

        it "returns file label from local fileset" do
          expect(subject.file_label).to eq("file.zip")
        end
      end

      context "with remote file" do
        before do
          allow(media_document).to receive(:is_remote_backed).and_return(true)
          allow(media_document).to receive(:remote_origin_url).and_return(["http://www.url.com/file.zip"])
        end

        it "returns nothing for file origin" do
          expect(subject.file_origin).to eq("Remote")
        end

        it "returns original file not ready when no mime type is present" do
          expect(subject.file_set_original_file_ready).to eq(false)
        end

        it "returns original file ready when mime type is present" do
          allow(representative_presenter).to receive(:mime_type).and_return("application/zip")
          expect(subject.file_set_original_file_ready).to eq(true)
        end

        it "returns file label from local fileset" do
          expect(subject.file_label).to eq("http://www.url.com/file.zip")
        end
      end
    end
  end

  describe "attachment files" do
    let(:pe) { SolrDocument.new({ id: "pe1" }) }

    before do
      allow(Morphosource::AttachmentService).to receive(:get).and_return(true)
    end

    it "returns media custom agreement attachment file URL" do
      expect(subject.attachment_url).to eq(["/attachments/#{media_document.id}?field=agreement"])
    end
  end

  describe 'universal viewer and derivatives' do
    let(:image_boolean) { false }
    let(:mesh_boolean) { false }
    let(:video_boolean) { false }
    let(:volume_boolean) { false }
    let(:iiif_enabled) { true }

    let(:read_permission) { true }

    before do
      allow(subject).to receive(:representative_presenter).and_return(representative_presenter)
      allow(subject).to receive(:file_set_presenters).and_return([representative_presenter])
      allow(ability).to receive(:can?).with(:read, file_set_document.id).and_return(read_permission)
      allow(representative_presenter).to receive(:image?).and_return(image_boolean)
      allow(representative_presenter).to receive(:mesh?).and_return(mesh_boolean)
      allow(representative_presenter).to receive(:video?).and_return(video_boolean)
      allow(representative_presenter).to receive(:volume?).and_return(volume_boolean)
      allow(Hyrax.config).to receive(:iiif_image_server?).and_return(iiif_enabled)
    end

    context "#universal_viewer?" do
      context 'with no representative_id' do
        it "returns false" do
          allow(subject).to receive(:representative_id).and_return(nil)
          expect(subject.universal_viewer?).to be false
        end
      end

      context "with no representative_presenter" do
        it "returns false" do
          allow(subject).to receive(:representative_presenter).and_return(nil)
          expect(subject.universal_viewer?).to be false
        end
      end

      context "when representative_presenter doesn't belong to any acceptable formats" do
        it "returns false" do
          expect(subject.universal_viewer?).to be false
        end
      end

      context "when IIIF is not enabled" do
        let(:iiif_enabled) { false }

        it "returns false" do
          expect(subject.universal_viewer?).to be false
        end
      end

      context "when representative_presenter is an image and all other conditions are met" do
        let(:image_boolean) { true }

        it "returns true" do
          expect(subject.universal_viewer?).to be true
        end

        context "but user does not have read permission" do
          let(:read_permission) { false }

          it "returns false" do
            expect(subject.universal_viewer?).to be false
          end
        end
      end

      context "when representative_presenter is a mesh and all other conditions are met" do
        let(:mesh_boolean) { true }

        it "returns true" do
          expect(subject.universal_viewer?).to be true
        end

        context "but user does not have read permission" do
          let(:read_permission) { false }

          it "returns false" do
            expect(subject.universal_viewer?).to be false
          end
        end
      end

      context "when representative_presenter is a video and all other conditions are met" do
        let(:video_boolean) { true }

        it "returns true" do
          expect(subject.universal_viewer?).to be true
        end

        context "but user does not have read permission" do
          let(:read_permission) { false }

          it "returns false" do
            expect(subject.universal_viewer?).to be false
          end
        end
      end

      context "when representative_presenter is a volume and all other conditions are met" do
        let(:volume_boolean) { true }

        it "returns true" do
          expect(subject.universal_viewer?).to be true
        end

        context "but user does not have read permission" do
          let(:read_permission) { false }

          it "returns false" do
            expect(subject.universal_viewer?).to be false
          end
        end
      end
    end
  end

  describe "parent work hierarchy methods" do
    let(:gparent_ie) { SolrDocument.new({ id: "ie1", has_model_ssim: ["ImagingEvent"] }) }
    let(:gparent_media) { SolrDocument.new({ id: "1", has_model_ssim: ["Media"] }) }
    let(:parent_pe) { SolrDocument.new({ id: "pe2", has_model_ssim: ["ProcessingEvent"] }) }
    let(:parent_media) { SolrDocument.new({ id: "2", has_model_ssim: ["Media"] }) }
    let(:ie) { SolrDocument.new({ id: "ie3", has_model_ssim: ["ImagingEvent"] }) }
    let(:pe) { SolrDocument.new({ id: "pe3", has_model_ssim: ["ProcessingEvent"] }) }

    ### Different behaviors based on parent work hierarchy ###

    context "with raw grand-parent media" do
      let(:hierarchy) { [gparent_ie, gparent_media, parent_pe, parent_media, pe] }

      before do
        allow(subject).to receive(:parent_works).and_return(hierarchy)
      end

      context "#all_parent_works" do
        it "returns whole work hierarchy" do
          expect(subject.all_parent_works).to eq(hierarchy)
        end
      end

      context "parent media methods" do
        context "#parent_media" do
          it "returns only parent media works" do
            expect(subject.parent_media).to eq([gparent_media, parent_media])
          end
        end

        context "#parent_media_id_list" do
          it "returns only parent media work IDs" do
            expect(subject.parent_media_id_list).to eq(["1", "2"])
          end
        end

        context "#parent_media_count" do
          it "returns count of parent media works" do
            expect(subject.parent_media_count).to eq("2")
          end
        end

        context "#top_parent_media" do
          it "returns grandparent media" do
            expect(subject.top_parent_media).to eq(gparent_media)
          end
        end

        context "#direct_parent" do
          it "returns parent media" do
            expect(subject.direct_parent).to eq(parent_media)
          end
        end

        context "#has_absentee_parent" do
          it "returns false" do
            expect(subject.has_absentee_parent).to eq(false)
          end
        end

        context "#imaging_event_editable?" do
          it "returns false" do
            expect(subject.imaging_event_editable?).to eq(false)
          end
        end

        context "#raw_or_derived" do
          it "returns derived" do
            expect(subject.raw_or_derived).to eq("Derived")
          end
        end

        context "#top_parent_media_raw_or_derived" do
          it "returns raw" do
            expect(subject.top_parent_media_raw_or_derived).to eq("Raw")
          end
        end
      end

      context "processing event methods" do
        context "#processing_events_data" do
          it "returns processing events" do
            expect(subject.processing_events_data.map { |data| data[:id]} ).to eq([parent_pe.id, pe.id])
          end
        end

        context "#processing_event_count" do
          it "returns count of processing events" do
            expect(subject.processing_event_count).to eq(2)
          end
        end

        context "#processing_activity_count" do
          it "returns count of processing event activities" do
            expect(subject.processing_activity_count).to eq(0)
          end
        end

        context "#this_media_processing_event" do
          it "returns this_media_processing_event" do
            expect(subject.this_media_processing_event[:id]).to eq(pe.id)
          end
        end
      end
    end

    context "with no present media parents, but absentee parent" do
      let(:hierarchy) { [ie, pe] }
      before do
        allow(subject).to receive(:parent_works).and_return(hierarchy)
      end

      context "#all_parent_works" do
        it "returns whole work hierarchy" do
          expect(subject.all_parent_works).to eq(hierarchy)
        end
      end

      context "parent media methods" do
        context "#parent_media" do
          it "returns empty array" do
            expect(subject.parent_media).to eq([])
          end
        end

        context "#parent_media_id_list" do
          it "returns empty array" do
            expect(subject.parent_media_id_list).to eq([])
          end
        end

        context "#parent_media_count" do
          it "returns 0 count of parent media works" do
            expect(subject.parent_media_count).to eq("0")
          end
        end

        context "#top_parent_media" do
          it "returns nil" do
            expect(subject.top_parent_media).to eq(nil)
          end
        end

        context "#direct_parent" do
          it "returns nil" do
            expect(subject.direct_parent).to eq(nil)
          end
        end

        context "#has_absentee_parent" do
          it "returns true" do
            expect(subject.has_absentee_parent).to eq(true)
          end
        end

        context "#imaging_event_editable?" do
          it "returns true" do
            expect(subject.imaging_event_editable?).to eq(true)
          end
        end

        context "#raw_or_derived" do
          it "returns derived" do
            expect(subject.raw_or_derived).to eq("Derived")
          end
        end

        context "#top_parent_media_raw_or_derived" do
          it "returns nil" do
            expect(subject.top_parent_media_raw_or_derived).to eq(nil)
          end
        end
      end

      context "processing event methods" do
        context "#processing_events_data" do
          it "returns processing events" do
            expect(subject.processing_events_data.map { |data| data[:id]} ).to eq([pe.id])
          end
        end

        context "#processing_event_count" do
          it "returns count of processing events" do
            expect(subject.processing_event_count).to eq(1)
          end
        end

        context "#processing_activity_count" do
          it "returns count of processing event activities" do
            expect(subject.processing_activity_count).to eq(0)
          end
        end

        context "#this_media_processing_event" do
          it "returns this_media_processing_event" do
            expect(subject.this_media_processing_event[:id]).to eq(pe.id)
          end
        end
      end
    end

    context "raw media" do
      let(:hierarchy) { [ie] }
      before do
        allow(subject).to receive(:parent_works).and_return(hierarchy)
      end

      context "#all_parent_works" do
        it "returns whole work hierarchy" do
          expect(subject.all_parent_works).to eq(hierarchy)
        end
      end

      context "parent media methods" do
        context "#has_absentee_parent" do
          it "returns false" do
            expect(subject.has_absentee_parent).to eq(false)
          end
        end

        context "#imaging_event_editable?" do
          it "returns true" do
            expect(subject.imaging_event_editable?).to eq(true)
          end
        end

        context "#raw_or_derived" do
          it "returns raw" do
            expect(subject.raw_or_derived).to eq("Raw")
          end
        end

        context "#top_parent_media_raw_or_derived" do
          it "returns nil" do
            expect(subject.top_parent_media_raw_or_derived).to eq(nil)
          end
        end
      end

      context "processing event methods" do
        context "#processing_events_data" do
          it "returns empty array" do
            expect(subject.processing_events_data).to eq([])
          end
        end

        context "#processing_event_count" do
          it "returns count of processing events" do
            expect(subject.processing_event_count).to eq(0)
          end
        end

        context "#processing_activity_count" do
          it "returns count of processing event activities" do
            expect(subject.processing_activity_count).to eq(0)
          end
        end

        context "#this_media_processing_event" do
          it "returns nil" do
            expect(subject.this_media_processing_event).to eq(nil)
          end
        end
      end
    end
  end

  describe "child work hierarchy methods" do
    let(:child1_media) { SolrDocument.new({ id: "1", has_model_ssim: ["Media"] }) }
    let(:child2_media) { SolrDocument.new({ id: "2", has_model_ssim: ["Media"] }) }

    context "media has children" do
      let(:child_media) { [child1_media, child2_media] }

      before do
        allow(subject).to receive(:direct_child_media_works).and_return(child_media)
        allow(subject).to receive(:related_media).and_return(child_media)
        allow(ability).to receive(:can?).with(:read, child1_media).and_return(true)
        allow(ability).to receive(:can?).with(:read, child2_media).and_return(false)
      end

      context "#child_media" do
        it "returns child media" do
          expect(subject.child_media).to eq(child_media)
        end
      end

      context "#viewable_child_media" do
        it "returns only readable child media" do
          expect(subject.viewable_child_media).to eq([child1_media])
        end
      end

      context "#child_media_id_list" do
        it "returns list of child media ids" do
          expect(subject.child_media_id_list).to eq(child_media.map(&:id))
        end
      end

      context "#has_child_media?" do
        it "returns true" do
          expect(subject.has_child_media?).to eq(true)
        end
      end
    end

    context "media has no children" do
      context "#child_media" do
        it "returns empty array" do
          expect(subject.child_media).to eq([])
        end
      end

      context "#viewable_child_media" do
        it "returns empty array" do
          expect(subject.viewable_child_media).to eq([])
        end
      end

      context "#child_media_id_list" do
        it "returns empty array" do
          expect(subject.child_media_id_list).to eq([])
        end
      end

      context "#has_child_media?" do
        it "returns false" do
          expect(subject.has_child_media?).to eq(false)
        end
      end
    end
  end

  describe "related media work methods" do
    let!(:media1) { create(:media_document) }
    let!(:media2) { create(:public_media_document) }
    let!(:media3) { create(:public_media_document) }
    let!(:parent_media) { create(:media_document) }
    let!(:child_media) { create(:public_media_document) }

    before do
      allow(subject).to receive(:parent_works).and_return([parent_media])
      allow(subject).to receive(:direct_child_media_works).and_return([child_media])
    end

    context "#related_media" do
      it "returns all related media" do
        expect(subject.related_media.map(&:id).sort).to eq([media1, media2, media3, parent_media, child_media].map(&:id).sort)
      end
    end

    context "#viewable_related_media" do
      it "returns only viewable related media" do
        expect(subject.viewable_related_media.map(&:id).sort).to eq([media2, media3, child_media].map(&:id).sort)
      end
    end

    context "#other_viewable_related_media" do
      it "returns viewable non-parent non-child media" do
        expect(subject.other_viewable_related_media.map(&:id).sort).to eq([media2, media3].map(&:id).sort)
      end
    end

    context "#user_facing_related_media_count" do
      it "returns count of viewable non-parent media plus count of parent media regardless of viewability" do
        expect(subject.user_facing_related_media_count).to eq(4)
      end
    end
  end

  describe "media member presenter" do
    it "is a Hyrax::MediaMemberPresenterFactory object" do
      expect(subject.send(:member_presenter_factory)).to be_a Hyrax::MediaMemberPresenterFactory
    end
  end

  describe 'processing_activity_hash' do
    # typical string
    let(:step1_string)  { "Step: 1, Type: Test Type, Software: Test Software, Description: Test Description"}
    let(:step1_hash)    { {"Description"=>"Test Description", "Software"=>"Test Software", "Step"=>"1", "Type"=>"Test Type"} }

    # text contains colons
    let(:step2_string)  { "Step: 2, Type: Transform: Rotation, Software: Test: Test, Description: Test: Test"}
    let(:step2_hash)    { {"Description"=>"Test: Test", "Software"=>"Test: Test", "Step"=>"2", "Type"=>"Transform: Rotation"} }

    # text contains match headings
    let(:step3_string)  { "Step: 3, Type: Type, Software: , Description: Type, Description: , Description: Description"}
    let(:step3_hash)    { {"Description"=>"Type, Description: , Description: Description", "Software"=>"", "Step"=>"3", "Type"=>"Type"} }

    # headings are empty
    let(:step4_string)  { "Step: 4, Type: , Software: , Description: "}
    let(:step4_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"4", "Type"=>""} }

    # the string is empty
    let(:step5_string)  { "" }
    let(:step5_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"", "Type"=>""} }

    # the string is nil
    let(:step6_string)  { nil }
    let(:step6_hash)    { {"Description"=>"", "Software"=>"", "Step"=>"", "Type"=>""} }

    it 'creates a hash of processing activity components' do
      expect(subject.send(:processing_activity_hash, step1_string)).to eq(step1_hash)
      expect(subject.send(:processing_activity_hash, step2_string)).to eq(step2_hash)
      expect(subject.send(:processing_activity_hash, step3_string)).to eq(step3_hash)
      expect(subject.send(:processing_activity_hash, step4_string)).to eq(step4_hash)
      expect(subject.send(:processing_activity_hash, step5_string)).to eq(step5_hash)
      expect(subject.send(:processing_activity_hash, step6_string)).to eq(step6_hash)
    end
  end
end
