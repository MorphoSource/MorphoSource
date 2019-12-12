# Generated via
#  `rails generate hyrax:work Taxonomy`
require 'rails_helper'

RSpec.describe Hyrax::TaxonomyForm do

  let(:taxonomy_terms) { [:taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies] }

  describe 'class attributes' do

    it 'has expected metadata terms' do
      taxonomy_terms.each do |term|
        expect(described_class.terms).to include(term)
      end
    end

    it 'has expected required metadata terms' do
      expect(described_class.required_fields).to match_array([])
    end

    it 'has expected single valued metadata terms' do
      expect(described_class.single_valued_fields).to match_array(taxonomy_terms)
    end

  end

end
