module Morphosource
  class PhysicalObjectForm < Hyrax::Forms::WorkForm
    include Morphosource::FormMethods
    include ChildCreateButton
    include SingleValuedForm

    class_attribute :single_value_fields

    self.terms += [:address,
                   :bibliographic_citation,
                   :catalog_number,
                   :city,
                   :collection_code,
                   :context,
                   :country,
                   :current_location,
                   :dating_method,
                   :dimensions,
                   :formation,
                   :institution_code,
                   :latitude,
                   :longitude,
                   :numeric_time,
                   :organization_id,
                   :original_location,
                   :periodic_time,
                   :provenance_date,
                   :provenance_details,
                   :provenance_location,
                   :provenance_name,
                   :state_province,
                   :tgn,
                   :vouchered]

    self.terms -= [:keyword,
                   :language,
                   :license,
                   :resource_type,
                   :rights_statement,
                   :source,
                   :subject,
                   :title]

    self.required_fields = []

    self.single_valued_fields = [:address,
                                 :catalog_number,
                                 :city,
                                 :collection_code,
                                 :context,
                                 :country,
                                 :current_location,
                                 :date_created,
                                 :dating_method,
                                 :description,
                                 :dimensions,
                                 :formation,
                                 :institution_code,
                                 :latitude,
                                 :longitude,
                                 :numeric_time,
                                 :original_location,
                                 :provenance_date,
                                 :provenance_details,
                                 :provenance_location,
                                 :provenance_name,
                                 :publisher,
                                 :state_province,
                                 :vouchered]

    def primary_terms
      required_fields + [:bibliographic_citation,
                         :catalog_number,
                         :collection_code,
                         :date_created,
                         :identifier,
                         :related_url]
    end

    def secondary_terms
      []
    end

    def self.build_permitted_params
      super + [ :organization_id, { tgn_attributes: [:id, :_destroy] } ]
    end

  end
end
