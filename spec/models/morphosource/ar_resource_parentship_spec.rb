# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::ArResourceParentship do
  before(:all) do
    class TestTaxonomyWithValkyrie < Taxonomy
      include Morphosource::Works::ValkyrieAssociation

      self.valid_child_concerns = [TaxonomyResource]
    end
  end

  before do
    allow_any_instance_of(Taxonomy).to receive(:readonly?).and_return(false)
  end

  after(:all) do
    Object.send(:remove_const, :TestTaxonomyWithValkyrie) if Object.const_defined?(:TestTaxonomyWithValkyrie)
  end

  let(:valkyrie_child)  { Hyrax.persister.save(resource: TaxonomyResource.new(title: ['Child Valkyrie Resource'])) }
  let(:valkyrie_parent) { Hyrax.persister.save(resource: TaxonomyResource.new(title: ['Parent Valkyrie Resource'])) }
  let(:af_parent)       { TestTaxonomyWithValkyrie.create(title: ['Parent AF Work']) }

  describe '#member_of' do
    it 'returns AF parents that have this resource as a valkyrie member' do
      af_parent.members = [valkyrie_child]
      af_parent.save!

      expect(valkyrie_child.member_of.map { |p| p.id.to_s }).to include(af_parent.id)
    end

    it 'returns Valkyrie parents' do
      valkyrie_parent.member_ids = [valkyrie_child.id]
      Hyrax.persister.save(resource: valkyrie_parent)

      expect(valkyrie_child.member_of.map(&:id)).to include(valkyrie_parent.id)
    end

    it 'returns both types of parents' do
      af_parent.members = [valkyrie_child]
      af_parent.save!
      valkyrie_parent.member_ids = [valkyrie_child.id]
      Hyrax.persister.save(resource: valkyrie_parent)

      parent_ids = valkyrie_child.member_of.map { |p| p.id.to_s }
      expect(parent_ids).to include(af_parent.id)
      expect(parent_ids).to include(valkyrie_parent.id.to_s)
    end

    it 'returns AF parents for a plain-AF child never linked via valkyrie_member_ids (e.g. an unmigrated FileSet)' do
      af_child = FileSet.create!(title: ['Child AF FileSet'])
      af_parent.ordered_members << af_child
      af_parent.save!

      expect(af_child.valkyrie_resource.member_of.map { |p| p.id.to_s }).to include(af_parent.id)
    end

    it 'deduplicates parents that appear in both Postgres and Solr' do
      # Simulate the hybrid migration window: the AF parent has been saved with
      # valkyrie_member_ids (so it appears in Solr via valkyrie_member_ids_ssim)
      # and also appears in the Postgres inverse-reference index.
      af_parent.members = [valkyrie_child]
      af_parent.save!

      postgres_result = double('pg_parent', id: af_parent.id)
      allow(Hyrax.query_service.postgres_service)
        .to receive(:find_inverse_references_by)
        .with(id: valkyrie_child.id.to_s, property: :member_ids)
        .and_return([postgres_result])

      # Both sources return the same parent ID; member_of must return it only once.
      result = valkyrie_child.member_of
      expect(result.map { |p| p.id.to_s }.tally.values).to all(eq(1))
    end
  end
end
