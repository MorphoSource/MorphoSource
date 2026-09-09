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

      # Migration normally requires saving from transaction, hence via_transaction: true
      persister.save(resource: af_child.reload.valkyrie_resource, via_transaction: true)

      # Reload parent to verify changes
      af_parent.reload

      # Verify AF membership is removed
      expect(af_parent.members).not_to include(af_child)
      expect(af_parent.ordered_members).not_to include(af_child)

      # Verify Valkyrie membership is added
      expect(af_parent.valkyrie_member_ids).to include(af_child.id.to_s)
    end

    it "raises rather than silently migrating a Wings-backed resource without via_transaction: true" do
      af_file_set = create(:file_set, user: create(:user))
      wings_file_set = Hyrax.query_service.find_by(id: af_file_set.id)
      expect(wings_file_set).to be_wings

      expect { persister.save(resource: wings_file_set) }
        .to raise_error(FreyjaWithWings::Persister::UnexpectedWingsResourceSaveError, /#{af_file_set.id}/)

      # nothing was migrated -- no Postgres row exists for this id
      expect(Valkyrie::Persistence::Postgres::ORM::Resource.where(id: af_file_set.id).exists?).to be false
    end

    it "allows saving a Wings-backed resource when via_transaction: true is passed" do
      af_file_set = create(:file_set, user: create(:user))
      wings_file_set = Hyrax.query_service.find_by(id: af_file_set.id)

      expect { persister.save(resource: wings_file_set, via_transaction: true) }.not_to raise_error

      expect(Valkyrie::Persistence::Postgres::ORM::Resource.where(id: af_file_set.id).exists?).to be true
    end
  end

  describe "#delete" do
    it "migrates an AF child to Valkyrie, then restores AF membership when that migrated child is deleted" do
      # Setup: Parent has AF child
      af_parent.ordered_members << af_child
      af_parent.save!

      # Verify initial state
      expect(af_parent.members).to include(af_child)

      # Enable transition config
      allow(Hyrax.config).to receive(:valkyrie_transition?).and_return(true)

      af_child.save!

      # Save the resource (simulating migration to Postgres, as the real transaction-mediated
      # save would -- via_transaction: true is required now that a bare save on a Wings-backed
      # resource raises)
      persister.save(resource: af_child.reload.valkyrie_resource, via_transaction: true)

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

    it "does not attempt AF membership reconciliation for a resource that isn't a Hyrax::Work or Hyrax::FileSet" do
      file_metadata = Hyrax.persister.save(resource: Hyrax::FileMetadata.new(file_set_id: 'irrelevant'))

      expect(ActiveFedora::Base).not_to receive(:exists?)

      persister.delete(resource: file_metadata)
    end

    it "raises rather than silently no-op'ing when asked to delete a Wings-backed Hyrax::FileSet" do
      af_file_set = create(:file_set, user: create(:user))
      wings_file_set = Hyrax.query_service.find_by(id: af_file_set.id)
      expect(wings_file_set).to be_wings

      expect { persister.delete(resource: wings_file_set) }
        .to raise_error(FreyjaWithWings::Persister::WingsFileSetDeleteError, /#{af_file_set.id}/)

      # the AF record is untouched -- the point is that this never reaches the
      # base Postgres persister's no-op delete in the first place
      expect(::FileSet.exists?(af_file_set.id)).to be true
    end
  end
end