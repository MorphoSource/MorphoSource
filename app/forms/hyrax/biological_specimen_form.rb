module Hyrax
  class BiologicalSpecimenForm < Morphosource::PhysicalObjectForm

    self.model_class = ::BiologicalSpecimen

    self.child_create_button = true

    self.terms += [:canonical_taxonomy,
                   :idigbio_recordset_id,
                   :idigbio_uuid,
                   :is_type_specimen,
                   :occurrence_id,
                   :organization_relationship,
                   :sex,
                   :taxonomy_id,
                   :vouchered]

    self.single_valued_fields += [:canonical_taxonomy,
                                  :idigbio_recordset_id,
                                  :idigbio_uuid,
                                  :is_type_specimen,
                                  :occurrence_id,
                                  :organization_relationship,
                                  :sex]

    # These show above the fold
    def primary_terms
      super + [:canonical_taxonomy,
               :institution_code,
               :organization_relationship]
    end

    def self.build_permitted_params
      super + [:taxonomy_id]
    end

  end
end
