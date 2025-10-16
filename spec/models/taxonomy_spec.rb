# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

# @deprecated Taxonomy spec tests should return errors.
RSpec.describe Taxonomy do

  describe "valid work relationships" do

    it "has no valid parents @deprecated ReadOnlyRecord" do
      # expect(subject.valid_parent_concerns).to match_array([])
      expect { subject.valid_parent_concerns }.to raise_error(ActiveFedora::ReadOnlyRecord)
    end

    it "has no valid child concerns @deprecated ReadOnlyRecord" do
      # expect(subject.valid_child_concerns).to match_array([])
      expect{ subject.valid_child_concerns }.to raise_error(ActiveFedora::ReadOnlyRecord)
    end
  end

  describe "instance" do
    it "is valid with valid attributes @deprecated ReadOnlyRecord" do
      # subject.title = ["title"]
      # subject.taxonomy_domain = ["domain"]
      # subject.taxonomy_kingdom = ["kingdom"]
      # subject.taxonomy_phylum = ["phylum"]
      # subject.taxonomy_superclass = ["superclass"]
      # subject.taxonomy_class = ["class"]
      # subject.taxonomy_subclass = ["subclass"]
      # subject.taxonomy_superorder = ["superorder"]
      # subject.taxonomy_order = ["order"]
      # subject.taxonomy_suborder = ["suborder"]
      # subject.taxonomy_superfamily = ["superfamily"]
      # subject.taxonomy_family = ["family"]
      # subject.taxonomy_subfamily = ["subfamily"]
      # subject.taxonomy_tribe = ["tribe"]
      # subject.taxonomy_genus = ["genus"]
      # subject.taxonomy_species = ["species"]
      # subject.taxonomy_subspecies = ["subspecies"]
      # subject.source = ["some source"]
      # subject.trusted = ["true"]
      # subject.gbif_key = ['111111']
      # expect(subject).to be_valid

      expect {
        subject.title = ["title"]
        subject.taxonomy_domain = ["domain"]
        subject.taxonomy_kingdom = ["kingdom"]
        subject.taxonomy_phylum = ["phylum"]
        subject.taxonomy_superclass = ["superclass"]
        subject.taxonomy_class = ["class"]
        subject.taxonomy_subclass = ["subclass"]
        subject.taxonomy_superorder = ["superorder"]
        subject.taxonomy_order = ["order"]
        subject.taxonomy_suborder = ["suborder"]
        subject.taxonomy_superfamily = ["superfamily"]
        subject.taxonomy_family = ["family"]
        subject.taxonomy_subfamily = ["subfamily"]
        subject.taxonomy_tribe = ["tribe"]
        subject.taxonomy_genus = ["genus"]
        subject.taxonomy_species = ["species"]
        subject.taxonomy_subspecies = ["subspecies"]
        subject.source = ["some source"]
        subject.trusted = ["true"]
        subject.gbif_key = ['111111']
      }.to raise_error(ActiveFedora::ReadOnlyRecord)
    end

    it "is not valid without required title field @deprecated ReadOnlyRecord" do
      # subject.title = []
      # subject.taxonomy_domain = ["domain"]
      # subject.taxonomy_kingdom = []
      # subject.taxonomy_phylum = ["phylum"]
      # subject.taxonomy_superclass = ["superclass"]
      # subject.taxonomy_class = []
      # subject.taxonomy_subclass = ["subclass"]
      # subject.taxonomy_superorder = ["superorder"]
      # subject.taxonomy_order = []
      # subject.taxonomy_suborder = ["suborder"]
      # subject.taxonomy_superfamily = ["superfamily"]
      # subject.taxonomy_family = ["family"]
      # subject.taxonomy_subfamily = ["subfamily"]
      # subject.taxonomy_tribe = []
      # subject.taxonomy_genus = []
      # subject.taxonomy_species = ["species"]
      # subject.taxonomy_subspecies = ["subspecies"]
      # subject.source = ["some source"]
      # subject.trusted = ["true"]
      # subject.gbif_key = ['111111']
      # expect(subject).to_not be_valid

      expect {
        subject.title = []
        subject.taxonomy_domain = ["domain"]
        subject.taxonomy_kingdom = []
        subject.taxonomy_phylum = ["phylum"]
        subject.taxonomy_superclass = ["superclass"]
        subject.taxonomy_class = []
        subject.taxonomy_subclass = ["subclass"]
        subject.taxonomy_superorder = ["superorder"]
        subject.taxonomy_order = []
        subject.taxonomy_suborder = ["suborder"]
        subject.taxonomy_superfamily = ["superfamily"]
        subject.taxonomy_family = ["family"]
        subject.taxonomy_subfamily = ["subfamily"]
        subject.taxonomy_tribe = []
        subject.taxonomy_genus = []
        subject.taxonomy_species = ["species"]
        subject.taxonomy_subspecies = ["subspecies"]
        subject.source = ["some source"]
        subject.trusted = ["true"]
        subject.gbif_key = ['111111']
      }.to raise_error(ActiveFedora::ReadOnlyRecord)
    end

    describe "valid work relationships" do

      it "has no valid parents @deprecated ReadOnlyRecord" do
        # expect(subject.valid_parent_concerns).to match_array([])
        expect{ subject.valid_parent_concerns }.to raise_error(ActiveFedora::ReadOnlyRecord)
      end

      it "has no valid child concerns @deprecated ReadOnlyRecord" do
        # expect(subject.valid_child_concerns).to match_array([])
        expect{ subject.valid_child_concerns }.to raise_error(ActiveFedora::ReadOnlyRecord)
      end

    end
  end

  describe 'media' do
    let(:taxonomy)      { Taxonomy.create(title: ['title']) }
    let(:specimen)      { BiologicalSpecimen.create(title: ['specimen'], vouchered: ['Yes'], taxonomy_id: [taxonomy.id]) }
    let(:device)        { Device.create(title: ['device'], modality: ['Photogrammetry']) }
    let(:imaging_event) { ImagingEvent.create(title: ['ie'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
    let(:pe1)           { ProcessingEvent.create(title: ['pe1']) }
    let(:media1)        { Media.create(title: ['media1']) }
    let(:pe2)           { ProcessingEvent.create(title: ['pe2']) }
    let(:media2)        { Media.create(title: ['media2']) }
    let(:pe3)           { ProcessingEvent.create(title: ['pe3']) }
    let(:media3)        { Media.create(title: ['media3']) }

    before do
      # Not needed when creating taxonomy returns ReadOnlyRecord error
      # imaging_event.ordered_members << media1
      # media1.ordered_members << pe1
      # pe1.ordered_members << media2
      # media2.ordered_members << pe3
      # pe3.ordered_members << media3
      # [imaging_event, pe1, media1, pe2, media2, pe3, media3].each(&:save)
    end

    it 'returns all descendant media @deprecated ReadOnlyRecord' do
      # expect(taxonomy.media).to match_array([media1, media2, media3])
      expect{ taxonomy.media }.to raise_error(ActiveFedora::ReadOnlyRecord)
    end
  end
end
