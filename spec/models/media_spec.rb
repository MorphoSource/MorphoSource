# Generated via
#  `rails generate hyrax:work Media`
require 'rails_helper'

RSpec.describe Media do

  describe "valid work relationships" do

    it "has ProcessingEvent, and ImagingEvent as valid parents" do
      expect(subject.valid_parent_concerns).to match_array([ProcessingEvent, ImagingEvent])
    end

    it "has ProcessingEvent as valid child" do
      expect(subject.valid_child_concerns).to match_array([ProcessingEvent])
    end

  end

  describe "instance" do
    subject { described_class.new }

    it_behaves_like 'a Morphosource work'

    it "is valid with valid attributes" do
        subject.title = ["foo"]
        subject.media_type = ["foo"]
        subject.side = nil
        subject.part = nil
        subject.orientation = nil
        subject.legacy_media_file_id = ["123"]
        subject.uuid = ["foo"]
        subject.ark = ["foo"]
        subject.doi = ["foo"]
        subject.available = ["foo"]
        subject.number_of_images_in_set = 33
        subject.x_spacing = ["foo"]
        subject.y_spacing = ["foo"]
        subject.z_spacing = ["foo"]
        subject.scale_bar = ["foo"]
        subject.unit = ["foo"]
        subject.map_type = ["foo"]
        # permissions defaults metadata
        subject.download_reviewer = ['foo']
        subject.agreement_uri = ['foo']
        subject.rights_statement = ['foo']
        subject.permits_commercial_use = ['foo']
        subject.permits_3d_use = ['foo']
        subject.rights_holder = ['foo']
        subject.funding = ['foo']
        subject.publisher = ['foo']
        subject.cite_as = ['foo']
        subject.preview_mode = ['No']
        expect(subject).to be_valid
    end

    it "is not valid without required fields - title, media_type" do
        subject.title = nil
        subject.media_type = nil
        subject.side = ["foo"]
        subject.part = nil
        subject.orientation = nil
        subject.funding = nil
        subject.cite_as = nil
        subject.rights_holder = ["foo"]
        subject.agreement_uri = ["foo"]
        subject.legacy_media_file_id = ["123"]
        subject.uuid = ["foo"]
        subject.ark = ["foo"]
        subject.doi = ["foo"]
        subject.available = ["foo"]
        subject.number_of_images_in_set = 33
        subject.x_spacing = ["foo"]
        subject.y_spacing = ["foo"]
        subject.z_spacing = ["foo"]
        subject.scale_bar = ["foo"]
        subject.unit = ["foo"]
        subject.map_type = ["foo"]
        expect(subject).to_not be_valid
    end

    describe "valid work relationships" do

      it "has ProcessingEvent, and ImagingEvent as valid parents" do
        expect(subject.valid_parent_concerns).to match_array([ProcessingEvent, ImagingEvent])
      end

      it "has ProcessingEvent as valid child" do
        expect(subject.valid_child_concerns).to match_array([ProcessingEvent])
      end

    end

    describe '#human_readable_media_type' do
      context 'media type is CTImageSeries' do
        before do
          subject.media_type = ['CTImageSeries']
        end
        it 'returns Volumetric Image Series' do
          expect(subject.human_readable_media_type).to eq ["Volumetric Image Series"]
        end
      end
      context 'media type is PhotogrammetryImageSeries' do
        before do
          subject.media_type = ['PhotogrammetryImageSeries']
        end
        it 'returns Photogrammetry Image Series' do
          expect(subject.human_readable_media_type).to eq ["Photogrammetry Image Series"]
        end
      end
      context 'media type is anything else' do
        before do
          subject.media_type = ['Anything Else']
        end
        it 'returns Anything Else' do
          expect(subject.human_readable_media_type).to eq ["Anything Else"]
        end
      end
    end

    describe '#modality' do
      let(:device)         { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
      let!(:imaging_event) { ImagingEvent.new(ie_modality: device.modality, device_id: [device.id.to_s]) }
      let(:modality_values) { {
        "MicroNanoXRayComputedTomography" => "X-Ray Computed Tomography (CT/microCT)",
        "MagneticResonanceImaging" => "Magnetic Resonance Imaging (MRI)",
        "PositronEmissionTomography" => "Positron Emission Tomography (PET)",
        "SinglePhotonEmissionComputedTomography" => "Single Photon Emission Computed Tomography (SPECT)",
        "NeutronComputedTomography" => "Neutron Computed Tomography (NCT)",
        "SynchrotronImaging" => "Synchrotron Imaging",
        "Photogrammetry" => "Photogrammetry",
        "StructuredLight" => "Structured Light",
        "LaserScan" => "Laser Scan",
        "ConfocalImageStacking" => "Confocal Image Stacking",
        "LightSheetFluorescenceMicroscopy" => "Light Sheet Fluorescence Microscopy",
        "Infrared" => "Infrared",
        "ReflectanceTransformationImaging" => "Reflectance Transformation Imaging",
        "Photography" => "Photography",
        "ScanningElectronMicroscopy" => "Scanning Electron Microscopy",
        "TransmissionElectronMicroscopy" => "Transmission Electron Microscopy",
        "BornDigital" => "Born Digital",
        "XRay" => "X-Ray",
        "LaserAidedProfiling" => "Laser Aided Profiling",
        "Video" => "Video"
        }
      }
      before do
        allow(subject).to receive(:imaging_event).and_return(imaging_event)
      end

      it 'returns the imaging event modality' do
        modality_values.each do |k,v|
          imaging_event.ie_modality = [k]
          expect(subject.modality).to eq k
          expect(subject.modality_label).to eq v
        end
      end
    end

    describe "#file_set_visibilities" do
      subject { described_class.new(title: ["Test Media Work"]) }

      let (:file_set1)  { FileSet.create(id: "1") }
      let (:file_set2)  { FileSet.create(id: "2") }
      let (:file_set3)  { FileSet.create(id: "3") }
      let (:file_set4)  { FileSet.create(id: "4") }
      let (:file_set5)  { FileSet.create(id: "5") }
      let (:file_sets)  { [file_set1, file_set2, file_set3, file_set4, file_set5] }

      context 'all file visibilities are public' do
        before do
          file_sets.each do |f|
            f.visibility =       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
            f.save
            subject.ordered_members << f
          end
          subject.save
        end
        it 'returns ["open"]' do
          expect(subject.file_set_visibilities).to match_array([Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC])
        end
      end
      context 'all file visibilities are private' do
        before do
          file_sets.each do |f|
            f.visibility =       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
            f.save
            subject.ordered_members << f
          end
          subject.save
        end
        it 'returns ["restricted"]' do
          expect(subject.file_set_visibilities).to match_array([Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE])
        end
      end
    end

    describe '#restricted?, #open?' do
      context 'fileset_accessibility is open' do
        before do
          subject.fileset_accessibility = ["open"]
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(true) }
      end
      context 'fileset_accessibility is restricted_download' do
        before do
          subject.fileset_accessibility = ["restricted_download"]
        end
        it { expect(subject.restricted?).to be(true) }
        it { expect(subject.open?).to be(false) }
      end
      context 'fileset_accessibility is preview_only' do
        before do
          subject.fileset_accessibility = ["preview_only"]
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(false) }
      end
      context 'fileset_accessibility is hidden' do
        before do
          subject.fileset_accessibility = ["hidden"]
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(false) }
      end
      context 'fileset_accessibility is private' do
        before do
          subject.fileset_accessibility = ["private"]
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(false) }
      end
      context 'fileset_accessibility is nil' do
        before do
          allow(subject).to receive(:fileset_accessibility).and_return(nil)
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(false) }
      end
      context 'fileset_accessibility is empty' do
        before do
          allow(subject).to receive(:fileset_accessibility).and_return([])
        end
        it { expect(subject.restricted?).to be(false) }
        it { expect(subject.open?).to be(false) }
      end
    end

    describe '#can_add_to_cart?' do
      subject { described_class.new }
      context 'media is open' do
        before do
          subject.visibility = 'open'
          subject.fileset_accessibility = ['open']
        end
        it { expect(subject.can_add_to_cart?).to be(true) }
      end
      context 'media is restricted' do
        before do
          subject.visibility = 'open'
          subject.fileset_accessibility = ['restricted_download']
        end
        it { expect(subject.can_add_to_cart?).to be(true) }
      end
    end

    describe '#publication_status' do
      let(:open) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      let(:private) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

      context 'media and files are open' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: [""], fileset_accessibility: ["open"]) }

        it { expect(subject.publication_status).to eq("open") }
      end

      context 'media is open, files are restricted' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: [""], fileset_accessibility: ["restricted_download"]) }

        it { expect(subject.publication_status).to eq("restricted") }
      end

      context 'media and files are both private' do
        subject { described_class.new(title: ["Test Media Work"], visibility: private, fileset_visibility: [""], fileset_accessibility: ["private"]) }

        it { expect(subject.publication_status).to eq("private") }
      end

      context 'media does not have a fileset_accessibity set' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: [""], fileset_accessibility: nil) }

        it { expect(subject.publication_status).to eq("private") }
      end
    end

    describe '#reviewer' do
      let(:download_reviewer) { double('User', ms_id: 'reviewer') }
      let(:depositor) { double('User', ms_id: 'depositor') }
      context 'there is no download_reviewer' do
        before do
          subject.download_reviewer = []
          subject.depositor = depositor.ms_id
        end
        it 'returns the depositor' do
          expect(subject.reviewer).to eq([depositor.ms_id])
        end
      end
      context 'there is a download_reviewer' do
        context 'the download_reviewer exists' do
          before do
            subject.download_reviewer = [download_reviewer.ms_id]
            subject.depositor = depositor.ms_id
            expect(User).to receive(:where).with(ms_id: ['reviewer']).and_return([download_reviewer])
          end
          it 'returns the reviewer' do
            expect(subject.reviewer).to eq([download_reviewer.ms_id])
          end
        end
        context 'the download_reviewer does not exist' do
          before do
            subject.depositor = depositor.ms_id
          end
          it 'returns the depositor' do
            expect(subject.reviewer).to eq([depositor.ms_id])
          end
        end
      end
    end

    describe 'ancestor physical objects' do
      let(:media)         { Media.create(title: ['title'], media_type: ['Image'])}
      let(:organization)  { Organization.create(title: ['organization'])}
      let(:specimen)      { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'], organization_id: [organization.id])}
      let(:cho)           { CulturalHeritageObject.create(title: ['cho'], vouchered: ['Yes'], organization_id: [organization.id])}
      let(:device)        { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry'])}
      let(:imaging_event) { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], ie_modality: device.modality)}

      context 'object is a specimen' do
        let(:works) {[imaging_event, media]}

        before do
          imaging_event.physical_object_id = [specimen.id]
          imaging_event.ordered_members << media

          works.each(&:save)
          works.each(&:reload)
        end

        it 'returns info about the specimen' do
          expect(media.physical_objects).to match_array([specimen])
          expect(media.physical_object_type).to eq("Biological Specimen")
          expect(media.organizations).to match_array([organization])
          expect(media.organization_titles).to match_array(organization.title)
        end
      end

      context 'object is a cultural heritage object' do
        let(:works) {[imaging_event, media]}

        before do
          imaging_event.physical_object_id = [cho.id]
          imaging_event.ordered_members << media
          works.each(&:save)
          works.each(&:reload)
        end

        it 'returns info about the specimen' do
          expect(media.physical_objects).to match_array([cho])
          expect(media.physical_object_type).to eq("Cultural Heritage Object")
          expect(media.organizations).to match_array([organization])
          expect(media.organization_titles).to match_array(organization.title)
        end
      end
    end

    describe 'related media ids' do
      #- Specimen1
      #
      #  - IE1
      #
      #    - PE1
      #      - Media1
      #
      #    - PE2
      #      - Media2
      let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
      let(:media1)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
      let(:media2)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
      let(:device)                  { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
      let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }
      let!(:processing_event1)       { ProcessingEvent.create(title: ['processing_event']) }
      let!(:processing_event2)       { ProcessingEvent.create(title: ['processing_event']) }
      let!(:works)                  { [ imaging_event, processing_event1, processing_event2 ] }

      before do
        imaging_event.ordered_members << processing_event1
        imaging_event.ordered_members << processing_event2
        processing_event1.ordered_members << media1
        processing_event2.ordered_members << media2
        works.each(&:save)
        works.each(&:reload)
      end

      it 'returns related media ids' do
        expect(media1.related_media_ids).to include(media2.id)
      end
    end

    describe 'fund code associations' do
      let(:user) { create(:user) }
      let(:fund_code) { FundCode.new(title: 'Test Title', description: 'Test Description', user: user) }
      let(:media) { Media.create(title: ['title'], media_type: ['Image'], visibility: 'open') }

      before do
        media.save!
        media.new_fund_code_association(fund_code)
      end

      it 'returns fund code and fund code associations' do
        expect(media.fund_code_associations.first).to eq(FundCodeMediaAssociation.first)
        expect(media.fund_codes.first).to eq(fund_code)
      end
    end

    describe 'member of teams and projects' do
      let(:media) { Media.create(title: ['title'], media_type: ['Image'], visibility: 'open') }
      let(:team)                    { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.to_global_id) }
      let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.to_global_id) }

      before do
        media.member_of_collections << team << project
        media.save
      end

      it 'returns team membership' do
        expect(media.member_of_teams).to match_array([team])
        expect(media.member_of_team_ids).to match_array([team.id])
      end

      it 'returns project membership' do
        expect(media.member_of_projects).to match_array([project])
        expect(media.member_of_project_ids).to match_array([project.id])
      end
    end

    describe 'record_original_objects, reindex_physical_objects' do
      let(:specimen)                { BiologicalSpecimen.create(title: ['Specimen'], vouchered: ['Yes']) }
      let(:media)                   { Media.create(title: ['title'], media_type: ['Image'], keyword: ['red', 'blue', 'yellow'], visibility: 'open') }
      let(:device)                  { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
      let(:imaging_event)           { ImagingEvent.create(title: ['title'], device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }
      let!(:processing_event)       { ProcessingEvent.create(title: ['processing_event']) }
      let!(:works)                  { [ imaging_event, processing_event, media, specimen ] }

      before do
        imaging_event.ordered_members << processing_event
        processing_event.ordered_members << media
        works.each(&:save!)
        allow(media).to receive(:physical_objects).and_return([specimen])
        ActiveJob::Base.queue_adapter = :test
      end

      it 'calls record_original_objects and reindex_physical_objects when a media is destroyed' do
        expect(media).to receive(:record_original_objects)
        expect(media).to receive(:reindex_physical_objects)
        media.destroy
      end

      it 'calls UpdateWorkIndexJob with the object id' do
        media.destroy
        expect(UpdateWorkIndexJob).to have_been_enqueued.with(specimen.id)
      end

    end

    describe 'check_for_organization_transfer' do
      let!(:media)        { Media.create(title: ['media'], visibility: 'restricted', organization_transfer_on_publish: true) }
      let!(:organization) { Organization.create(title: ['organization'], permissions_enforcement_mode: []) }

      before do
        allow(media).to receive(:visibility_changed?).and_return(true)
        allow(media).to receive(:visibility).and_return('open')
        allow(media).to receive(:organizations).and_return([organization])
      end

      it 'calls transfer_media_to_organization' do
        expect { media.check_for_organization_transfer }.to have_enqueued_job(TransferToOrganizationJob)
      end
    end

    describe 'transfer_media_to_organization' do
      let(:data_manager)          { create(:user) }
      let(:depositor)             { create(:user) }
      let!(:contributor_role)     { Role.create(name: 'contributor') }
      let(:media)                 { Media.create(title: ['media'], depositor: depositor.ms_id, visibility: 'restricted', fileset_accessibility: ['private'], organization_transfer_on_publish: true) }

      before do
        data_manager.make_contributor
        allow(media).to receive(:visibility_changed?).and_return(true)
        allow(media).to receive(:visibility).and_return('open')
        allow(media).to receive(:organizations).and_return([organization])
      end

      context 'organization is an organization work' do
        let!(:organization)         { Organization.create(title: ['organization'], permissions_enforcement_mode: nil, data_manager: [data_manager.ms_id]) }

        context 'conditions are met for transferring media' do
          before do
            media.transfer_media_to_organization
          end
          it 'creates a new ProxyDepositRequest' do
            expect(ProxyDepositRequest.where(work_id: media.id, receiving_user: data_manager.id, sending_user: depositor.id, organization_transfer: true).count).to eq(1)
          end
        end

        context 'organization does not have a data manager set' do
          before do
            organization.data_manager = []
            organization.save
          end
          it 'raises an error and logs the details' do
            message = "Failed to transfer management of media #{media.id} to organization #{organization.id} with data manager #{organization.data_manager}"
            expect(Rails.logger).to receive(:fatal).with(message)
            expect { media.transfer_media_to_organization }.to raise_error
          end
        end
      end

      context 'organization is an organization collection' do
        let(:contributor_role)        { Role.create(name: 'contributor') }
        let(:organization_depositor)  { User.create(email: 'org_depositor@email.com', password: 'password') }
        let!(:organization)           { FactoryBot.create(:organization_collection, depositor: organization_depositor.ms_id, media_ownership_transfer: true) }

        before do
          organization_depositor.make_contributor
          organization.managers << organization_depositor
          organization.managers_group.save
        end

        context 'conditions are met for transferring media' do
          before do
            allow(User).to receive(:find_by).and_call_original
            media.transfer_media_to_organization
          end

          it 'creates a new ProxyDepositRequest' do
            expect(ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, sending_user: depositor.id, organization_transfer: true).count).to eq(1)
          end

          context 'owner is an organization manager' do
            let(:organization_depositor)  { depositor }

            context 'media owner and on_behalf_of is blank' do

              it 'does not create a new ProxyDepositRequest' do
                expect(ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, sending_user: depositor.id, organization_transfer: true).count).to eq(0)
              end

              it 'assigns the organization as owner' do
                expect(media.owner).to eq(organization.id)
              end
            end

            context 'media owner is blank' do
              let!(:media) { Media.create(title: ['media'], depositor: data_manager.ms_id, visibility: 'restricted', fileset_accessibility: ['private'], organization_transfer_on_publish: true, on_behalf_of: depositor.ms_id) }

              it 'does not create a new ProxyDepositRequest' do
                expect(ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, sending_user: depositor.id, organization_transfer: true).count).to eq(0)
              end

              it 'assigns the organization as owner' do
                expect(media.owner).to eq(organization.id)
              end
            end

            context 'media on_behalf_of is blank' do
              let!(:media) { Media.create(title: ['media'], depositor: data_manager.ms_id, visibility: 'restricted', fileset_accessibility: ['private'], organization_transfer_on_publish: true, owner: depositor.ms_id) }

              it 'does not create a new ProxyDepositRequest' do
                expect(ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, sending_user: depositor.id, organization_transfer: true).count).to eq(0)
              end

              it 'assigns the organization as owner' do
                expect(media.owner).to eq(organization.id)
              end
            end
          end
        end
      end
    end

    describe 'owner_class' do
      let(:media)         { FactoryBot.build(:media, owner: owner) }

      context 'owner is a user' do
        let(:owner) { FactoryBot.create(:contributor).ms_id }

        it { expect(media.owner_class).to eq(User) }
      end

      context 'owner is an organization collection' do
        let(:depositor) { FactoryBot.create(:contributor) }
        let(:owner)     { FactoryBot.create(:organization_collection, depositor: depositor.ms_id).id }

        it { expect(media.owner_class).to eq(OrganizationCollection) }
      end

      context 'owner is nil' do
        let(:owner) { nil }

        it { expect(media.owner_class).to be(nil) }
      end
    end
  end
end

describe 'description attachment methods' do
  let(:media) { Media.create }
  let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
  let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
  let(:valid_file_upload_url) { "/uploads/works/media/attachments/agreement/text.txt" }

  describe '#agreement_uploader' do
    it 'initializes an agreement_uploader with the correct work_id' do
      agreement_uploader = media.agreement_uploader
      expect(agreement_uploader).to be_an_instance_of(MediaAgreementAttachmentUploader)
      expect(agreement_uploader.work_id).to eq(media.id)
    end
  end

  describe '#agreement_attachment=' do
    context 'when assigning a valid file' do
      it 'stores the file and sets the agreement_attachment_url' do
        media.agreement_attachment = valid_file
        expect(media.agreement_attachment_url).to eq(valid_file_upload_url)
        expect(File.exist?(media.agreement_uploader.file.path)).to be_truthy
      end
    end

    context 'when assigning an invalid file' do
      it 'raises an error for unsupported file format' do
        expect {
          media.agreement_attachment = invalid_file
        }.to raise_error(ArgumentError, /Invalid file format: .jpg/)
      end
    end

    context 'when assigning nil' do
      before do
        media.agreement_attachment = valid_file
        expect(media.agreement_attachment_url).to be_present
      end

      it 'deletes the attachment and clears the agreement_attachment_url' do
        file_path = media.agreement_uploader.file.path
        expect(File.exist?(file_path)).to be_truthy

        media.agreement_attachment = nil
        expect(media.agreement_attachment_url).to be_nil
        expect(File.exist?(file_path)).to be_falsey
      end

      it 'logs a warning if the file does not exist' do
        allow(File).to receive(:exist?).and_return(false)
        expect(Rails.logger).to receive(:warn).with(/File not found/)
        media.agreement_attachment = nil
      end
    end
  end

  describe '#agreement_attachment' do
    it 'returns the agreement_attachment_url' do
      media.agreement_attachment = valid_file
      expect(media.agreement_attachment).to eq(media.agreement_attachment_url)
    end
  end

  describe '#destroy_file_sets (after_destroy)' do
    let(:fs1) { instance_double('FileSet', id: 'fs-destroy-1') }
    let(:fs2) { instance_double('FileSet', id: 'fs-destroy-2') }
    let(:media_instance) { Media.new }

    before do
      allow(media_instance).to receive(:file_set_ids).and_return(['fs-destroy-1', 'fs-destroy-2'])
      allow(FileSet).to receive(:find).with('fs-destroy-1').and_return(fs1)
      allow(FileSet).to receive(:find).with('fs-destroy-2').and_return(fs2)
      allow(fs1).to receive(:destroy)
      allow(fs2).to receive(:destroy)
    end

    it 'destroys each associated FileSet' do
      expect(fs1).to receive(:destroy)
      expect(fs2).to receive(:destroy)
      media_instance.send(:destroy_file_sets)
    end

    it 'continues if one FileSet raises (logs error, does not propagate)' do
      allow(fs1).to receive(:destroy).and_raise(StandardError, 'Fedora error')
      expect(Rails.logger).to receive(:error).with(/fs-destroy-1/)
      expect { media_instance.send(:destroy_file_sets) }.not_to raise_error
      expect(fs2).to have_received(:destroy)
    end
  end
end
