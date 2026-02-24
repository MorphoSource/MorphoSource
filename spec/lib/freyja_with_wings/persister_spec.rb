require 'rails_helper'

RSpec.describe FreyjaWithWings::Persister do
  before(:all) do
    class TestTaxonomyWithValkyrie < Taxonomy
      include Morphosource::Works::ValkyrieAssociation
      self.valid_child_concerns = [Taxonomy, TaxonomyResource]
    end
  end

  before do
    allow_any_instance_of(Taxonomy).to receive(:readonly?).and_return(false)
  end

  after(:all) do
    Object.send(:remove_const, :TestTaxonomyWithValkyrie) if Object.const_defined?(:TestTaxonomyWithValkyrie)
  end

  let(:adapter) { FreyjaWithWings::MetadataAdapter.new }
  let(:persister) { adapter.persister }
  let(:af_parent) { TestTaxonomyWithValkyrie.create(title: ['Parent AF Work']) }
  let(:af_child) { Taxonomy.create(title: ['Child AF Work']) }

  describe "#save" do
    it "migrates a child AF work to Valkyrie and updates the parent's membership" do
      # Setup: Parent has AF child
      af_parent.ordered_members << af_child
      af_parent.save!

      # Verify initial state
      expect(af_parent.members).to include(af_child)

      # Enable transition config
      allow(Hyrax.config).to receive(:valkyrie_transition?).and_return(true)

      af_child.save!

      # Save the resource (simulating migration to Postgres)
      persister.save(resource: af_child.reload.valkyrie_resource)

      # Reload parent to verify changes
      af_parent.reload

      # Verify AF membership is removed
      expect(af_parent.members).not_to include(af_child)
      expect(af_parent.ordered_members).not_to include(af_child)

      # Verify Valkyrie membership is added
      expect(af_parent.valkyrie_member_ids).to include(af_child.id.to_s)
    end
  end

  describe "#delete" do
    it "updates an AF parent's membership when a child is deleted and has an AF representation" do
      # Setup: Parent has AF child
      af_parent.ordered_members << af_child
      af_parent.save!

      # Verify initial state
      expect(af_parent.members).to include(af_child)

      # Enable transition config
      allow(Hyrax.config).to receive(:valkyrie_transition?).and_return(true)

      af_child.save!

      # Save the resource (simulating migration to Postgres)
      persister.save(resource: af_child.reload.valkyrie_resource)

      # Reload parent to verify changes
      af_parent.reload

      # Verify AF membership is removed
      expect(af_parent.members).not_to include(af_child)
      expect(af_parent.ordered_members).not_to include(af_child)

      # Verify Valkyrie membership is added
      expect(af_parent.valkyrie_member_ids).to include(af_child.id)

      # Now delete Valkyrie representation, falling back to AF representation by default
      valkyrie_child = Hyrax.query_service.find_by(id: af_child.id)
      persister.delete(resource: valkyrie_child)

      # Reload parent to verify changes
      af_parent.reload

      # Verify Valkyrie membership is removed
      expect(af_parent.valkyrie_member_ids).not_to include(af_child.id)

      # Verify AF membership is added
      expect(af_parent.members).to include(af_child)
      expect(af_parent.ordered_members).to include(af_child)
    end
  end
end