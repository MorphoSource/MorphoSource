# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Taxonomy do

  describe "valid work relationships" do

    it "has no valid parents" do
      expect(subject.valid_parent_concerns).to match_array([])
    end

    it "has Biological Specimen as its valid child concern" do
      expect(subject.valid_child_concerns).to match_array([BiologicalSpecimen])
    end
  end

  describe "instance" do
    subject { described_class.new }

    it "is valid with valid attributes" do
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
      expect(subject).to be_valid
    end

    it "is not valid without required title field" do
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
      expect(subject).to_not be_valid
    end

    describe "valid work relationships" do

      it "has no valid parents" do
        expect(subject.valid_parent_concerns).to match_array([])
      end

      it "has BiologicalSpecimen as its only valid child concern" do
        expect(subject.valid_child_concerns).to match_array([BiologicalSpecimen])
      end

    end
  end
end
