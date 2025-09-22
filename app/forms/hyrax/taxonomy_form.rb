# Generated via
#  `rails generate hyrax:work Taxonomy`
module Hyrax
  # Generated form for Taxonomy
  class TaxonomyForm < Hyrax::Forms::WorkForm
    self.model_class = ::Taxonomy
    include Morphosource::FormMethods
    include SingleValuedForm

    class_attribute :single_value_fields

    # Remove all default Hyrax metadata
    self.terms -= [:title, :creator, :contributor, :description, :keyword, 
      :license, :rights_statement, :publisher, :date_created, :subject, 
      :language, :identifier, :based_near, :related_url, :source, 
      :abstract, :access_right, :alternative_title, :rights_notes, :bibliographic_citation
    ]
    self.terms += [:taxonomy_domain, :taxonomy_kingdom, :taxonomy_phylum, 
      :taxonomy_superclass, :taxonomy_class, :taxonomy_subclass, 
      :taxonomy_superorder, :taxonomy_order, :taxonomy_suborder, 
      :taxonomy_superfamily, :taxonomy_family, :taxonomy_subfamily, 
      :taxonomy_tribe, :taxonomy_genus, :taxonomy_subgenus, :taxonomy_species, 
      :taxonomy_subspecies, :gbif_key
    ]

    self.required_fields = []

    self.single_valued_fields = self.terms - [:files, :visibility_during_embargo, :embargo_release_date,
      :visibility_after_embargo, :visibility_during_lease,
      :lease_expiration_date, :visibility_after_lease, :visibility,
      :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
      :member_of_collection_ids, :in_works_ids, :admin_set_id]

    def primary_terms
      self.terms - [:gbif_key] - [:files, :visibility_during_embargo, :embargo_release_date,
        :visibility_after_embargo, :visibility_during_lease,
        :lease_expiration_date, :visibility_after_lease, :visibility,
        :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
        :member_of_collection_ids, :in_works_ids, :admin_set_id]
    end

    def secondary_terms
      []
    end

  end
end
