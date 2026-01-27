require 'rails_helper'

RSpec.describe Morphosource::Works::ValkyrieAssociation do
  # Define a temporary test class inheriting from Taxonomy to isolate changes.
  # This effectively "opens up" Taxonomy logic for this test suite without
  # permanently modifying the global Taxonomy class.
  before(:all) do
    class TestTaxonomyWithValkyrie < Taxonomy
      include Morphosource::Works::ValkyrieAssociation

      # Override the class attribute only for this subclass
      self.valid_child_concerns = [Taxonomy, TaxonomyResource]
    end
  end

  before do
    allow_any_instance_of(Taxonomy).to receive(:readonly?).and_return(false)
  end

  # Clean up the constant after tests to avoid namespace pollution
  after(:all) do
    Object.send(:remove_const, :TestTaxonomyWithValkyrie) if Object.const_defined?(:TestTaxonomyWithValkyrie)
  end

  let(:af_parent) { TestTaxonomyWithValkyrie.create(title: ['Parent AF Work']) }

  # Create and save a Valkyrie resource using the Hyrax persister
  let(:valkyrie_child) do
    resource = TaxonomyResource.new(title: ['Child Valkyrie Resource'])
    Hyrax.persister.save(resource: resource)
  end

  let(:af_child) { Taxonomy.create(title: ['Child AF Work']) }

  describe "hybrid membership" do
    it "can assign both ActiveFedora and Valkyrie members" do
      # Assign a mix of AF and Valkyrie objects
      af_parent.ordered_members = [af_child, valkyrie_child]
      af_parent.save!

      af_parent.reload

      # Verify the members getter returns a proxy containing both
      expect(af_parent.ordered_members).to be_a(Morphosource::Works::ValkyrieAssociation::HybridMemberProxy)
      expect(af_parent.ordered_members).to include(af_child)
      expect(af_parent.ordered_members).to include(valkyrie_child)

      expect(af_parent.members).to be_a(Morphosource::Works::ValkyrieAssociation::HybridMemberProxy)
      expect(af_parent.members).to include(af_child)
      expect(af_parent.members).to include(valkyrie_child)

      # Verify IDs to ensure members are present
      expect(af_parent.ordered_member_ids).to include(af_child.id, valkyrie_child.id.to_s)
      expect(af_parent.member_ids).to include(af_child.id, valkyrie_child.id.to_s)

      # Verify the different methods
      expect(af_parent.valkyrie_member_ids).to include(valkyrie_child.id.to_s)
      expect(af_parent.valkyrie_member_ids).not_to include(af_child.id)
      expect(af_parent.active_fedora_ordered_members.to_a).to include(af_child)
      expect(af_parent.active_fedora_ordered_members.to_a).not_to include(valkyrie_child)
    end

    it "persists valkyrie_member_ids separately from AF members" do
      af_parent.members = [valkyrie_child]
      af_parent.save!
      af_parent.reload

      # The module should store Valkyrie IDs in the dedicated property
      expect(af_parent.valkyrie_member_ids).to include(valkyrie_child.id.to_s)
      # And standard AF members should be empty
      expect(af_parent.active_fedora_members.to_a).to be_empty
    end

    it "can remove members individually" do
      # Setup initial state with both members
      af_parent.ordered_members = [af_child, valkyrie_child]
      af_parent.save!
      af_parent.reload

      # Remove Valkyrie member
      af_parent.ordered_members.delete(valkyrie_child)
      af_parent.members.delete(valkyrie_child)
      af_parent.save!
      af_parent.reload

      # Verify Valkyrie member is gone but AF member remains
      expect(af_parent.valkyrie_member_ids).not_to include(valkyrie_child.id.to_s)
      expect(af_parent.active_fedora_ordered_members.to_a).to include(af_child)
      expect(af_parent.ordered_members).not_to include(valkyrie_child)
      expect(af_parent.ordered_members).to include(af_child)
      expect(af_parent.members).not_to include(valkyrie_child)
      expect(af_parent.members).to include(af_child)

      # Remove ActiveFedora member
      af_parent.ordered_members.delete(af_child)
      af_parent.members.delete(af_child)
      af_parent.save!
      af_parent.reload

      # Verify everything is empty
      expect(af_parent.valkyrie_member_ids).to be_empty
      expect(af_parent.active_fedora_ordered_members.to_a).to be_empty
      expect(af_parent.ordered_members).to be_empty
      expect(af_parent.members).to be_empty
    end

    it "respects the modified valid_child_concerns" do
      # This confirms that our subclass configuration is working
      expect(TestTaxonomyWithValkyrie.valid_child_concerns).to include(TaxonomyResource)
    end
  end
end