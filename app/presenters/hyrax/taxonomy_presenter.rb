# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  class TaxonomyPresenter < Hyrax::WorkShowPresenter
    include Morphosource::PresenterMethods

    delegate :taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, :taxonomy_subspecies, :trusted, to: :solr_document

    def biological_specimens
      work.members
    end

  end
end
