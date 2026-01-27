require 'rails_helper'

RSpec.describe Morphosource::ArResourceMembership do
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

  let(:valkyrie_parent) do
    resource = TaxonomyResource.new(title: ['Parent Valkyrie Resource'])
    Hyrax.persister.save(resource: resource)
  end

  let(:valkyrie_child) do
    resource = TaxonomyResource.new(title: ['Child Valkyrie Resource'])
    Hyrax.persister.save(resource: resource)
  end

  let(:af_child) { TestTaxonomyWithValkyrie.create(title: ['Child AF Work']) }
  let(:af_parent) { TestTaxonomyWithValkyrie.create(title: ['Parent AF Work']) }

  describe '#members' do
    it 'returns both Valkyrie and ActiveFedora members' do
      valkyrie_parent.member_ids = [valkyrie_child.id, ::Valkyrie::ID.new(af_child.id)]
      Hyrax.persister.save(resource: valkyrie_parent)

      reloaded_parent = Hyrax.query_service.find_by(id: valkyrie_parent.id)

      members = reloaded_parent.members
      expect(members).to include(valkyrie_child)
      expect(members.map { |m| m.try(:id).to_s }).to include(af_child.id)
    end

    it 'can filter to exclude AF works' do
      valkyrie_parent.member_ids = [valkyrie_child.id, ::Valkyrie::ID.new(af_child.id)]
      Hyrax.persister.save(resource: valkyrie_parent)

      reloaded_parent = Hyrax.query_service.find_by(id: valkyrie_parent.id)

      members = reloaded_parent.members(include_af_works: false)
      expect(members).to include(valkyrie_child)
      expect(members.map { |m| m.try(:id).to_s }).not_to include(af_child.id)
    end
  end

  describe '#member_of' do
    it 'returns AF parents that have this resource as a valkyrie member' do
      af_parent.members = [valkyrie_child]
      af_parent.save!

      parents = valkyrie_child.member_of
      expect(parents.map { |p| p.id.to_s }).to include(af_parent.id)
    end

    it 'returns Valkyrie parents' do
      valkyrie_parent.member_ids = [valkyrie_child.id]
      Hyrax.persister.save(resource: valkyrie_parent)

      parents = valkyrie_child.member_of
      expect(parents.map(&:id)).to include(valkyrie_parent.id)
    end

    it 'returns both types of parents' do
      af_parent.members = [valkyrie_child]
      af_parent.save!

      valkyrie_parent.member_ids = [valkyrie_child.id]
      Hyrax.persister.save(resource: valkyrie_parent)

      parents = valkyrie_child.member_of
      parent_ids = parents.map { |p| p.id.to_s }

      expect(parent_ids).to include(af_parent.id)
      expect(parent_ids).to include(valkyrie_parent.id.to_s)
    end
  end
end