# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  # Generated form for Taxonomy
  class TaxonomyForm < Hyrax::Forms::WorkForm
    self.model_class = ::Taxonomy
    include Morphosource::FormMethods
    include SingleValuedForm

    class_attribute :single_value_fields

    self.terms = [:taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies]

    self.required_fields = []

    self.single_valued_fields = self.terms

    def primary_terms
      self.terms
    end

  end
end
