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
        subject.terms_of_use = ['foo']
        subject.permits_commercial_use = ['foo']
        subject.permits_3d_use = ['foo']
        subject.rights_holder = ['foo']
        subject.funding = ['foo']
        subject.publisher = ['foo']
        subject.cite_as = ['foo']
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
          subject.fileset_accessibility = ['open']
        end
        it { expect(subject.can_add_to_cart?).to be(true) }
      end
      context 'media is on lease' do
        before do
          allow(subject).to receive(:active_lease?).and_return(true)
        end
        it { expect(subject.can_add_to_cart?).to be(true) }
      end
      context 'media is restricted' do
        before do
          subject.fileset_accessibility = ['restricted_download']
        end
        it { expect(subject.can_add_to_cart?).to be(true) }
      end
      context 'media is preview onoy' do
        before do
          subject.fileset_accessibility = ['preview_only']
        end
        it { expect(subject.can_add_to_cart?).to be(false) }
      end
      context 'media is hidden' do
        before do
          subject.fileset_accessibility = ['hidden']
        end
        it { expect(subject.can_add_to_cart?).to be(false) }
      end
      context 'media is under embargo' do
        before do
          allow(subject).to receive(:under_embargo?).and_return(true)
        end
        it { expect(subject.can_add_to_cart?).to be(false) }
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
      context 'media is open, files are preview only' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: [""], fileset_accessibility: ["preview_only"]) }

        it { expect(subject.publication_status).to eq("preview") }
      end
      context 'media is open, files are hidden' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: ["Restricted"], fileset_accessibility: ["hidden"]) }

        it { expect(subject.publication_status).to eq("hidden") }
      end
      context 'media and files are both private' do
        subject { described_class.new(title: ["Test Media Work"], visibility: private, fileset_visibility: [""], fileset_accessibility: ["private"]) }

        it { expect(subject.publication_status).to eq("private") }
      end
      context 'media and files are under embargo' do
        subject { described_class.new(title: ["Test Media Work"], visibility: private, fileset_visibility: [""], fileset_accessibility: [""]) }
        let(:embargo) { double("Embargo")}

        before do
          allow(embargo).to receive(:active?).and_return(true)
          allow(subject).to receive(:embargo).and_return(embargo)
        end

        it { expect(subject.publication_status).to eq("embargo") }
      end
      context 'media and files are under a lease' do
        subject { described_class.new(title: ["Test Media Work"], visibility: open, fileset_visibility: [""], fileset_accessibility: [""]) }
        let(:lease) { double("Lease")}

        before do
          allow(lease).to receive(:active?).and_return(true)
          allow(subject).to receive(:lease).and_return(lease)
        end

        it { expect(subject.publication_status).to eq("lease") }
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
          expect(subject.reviewer).to eq(depositor.ms_id)
        end
      end
      context 'there is a download_reviewer' do
        context 'the download_reviewer exists' do
          before do
            subject.download_reviewer = [download_reviewer.ms_id]
            subject.depositor = depositor.ms_id
            expect(User).to receive(:find_by).with(ms_id: 'reviewer').and_return(download_reviewer)
          end
          it 'returns the reviewer' do
            expect(subject.reviewer).to eq(download_reviewer.ms_id)
          end
        end
        context 'the download_reviewer does not exist' do
          before do
            subject.depositor = depositor.ms_id
          end
          it 'returns the depositor' do
            expect(subject.reviewer).to eq(depositor.ms_id)
          end
        end
      end
    end
  end
end
