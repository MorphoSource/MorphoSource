require 'rails_helper'

# Most of this module is from Hyrax, only testing the MorphoSource additions for membership
RSpec.describe Wings::ModelTransformer do
  before(:all) do
    class TestTaxonomyWithValkyrie < Taxonomy
      include Morphosource::Works::ValkyrieAssociation
      self.valid_child_concerns = [Taxonomy, TaxonomyResource]
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestTaxonomyWithValkyrie) if Object.const_defined?(:TestTaxonomyWithValkyrie)
  end

  let(:af_parent) { TestTaxonomyWithValkyrie.create(title: ['Parent AF Work']) }
  let(:af_child) { Taxonomy.create(title: ['Child AF Work']) }
  let(:valkyrie_child) do
    resource = TaxonomyResource.new(title: ['Child Valkyrie Resource'])
    Hyrax.persister.save(resource: resource)
  end

  describe '.for' do
    it 'includes both AF and Valkyrie members in the resulting resource member_ids' do
      # Add AF child
      af_parent.ordered_members << af_child

      # Add Valkyrie child
      af_parent.valkyrie_member_ids = [valkyrie_child.id.to_s]

      af_parent.save!

      resource = described_class.for(af_parent)

      expect(resource).to be_a(Hyrax::Work)
      expect(resource.member_ids).to include(valkyrie_child.id)
      expect(resource.member_ids).to include(::Valkyrie::ID.new(af_child.id))
    end
  end
end
