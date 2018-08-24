# Generated via
#  `rails generate hyrax:work PhysicalObject`
module Hyrax
  # Generated form for PhysicalObject
  # class PhysicalObjectForm < ::SingleValueForm
  class PhysicalObjectForm < Hyrax::Forms::WorkForm

    include SingleValuedForm

    class_attribute :single_value_fields

    self.model_class = ::PhysicalObject

    # terms already included as part of Hyrax basic metadata are commented out
    self.terms += [
       # bibliographic_citation should be included in Hyrax Basic Metadata, but causes errors if commented out
       :physical_object_type,
       :bibliographic_citation,
       :catalog_number,
       :collection_code,
       :current_location,
       # :date_created,
       # :description,
       # :identifier,
       :institution,
       :numeric_time,
       :original_location,
       :periodic_time,
       # :publisher,
       # :related_url,
       # :title,
       :vouchered,

       # Biological Specimens only
       :idigbio_recordset_id,
       :idigbio_uuid,
       :is_type_specimen,
       :occurrence_id,
       :sex,

       # CHOs only
       :cho_type,

       # :contributor,
       # :creator,
       :material
    ]

    self.terms -= [:based_near, :keyword, :license, :rights_statement, :subject, :language, :source, :resource_type]

    self.required_fields = [:title, :vouchered, :physical_object_type]

    self.single_valued_fields = [
      :bibliographic_citation,
      :catalog_number,
      :collection_code,
      :current_location,
      :date_created,
      :description,
      :institution,
      :numeric_time,
      :original_location,
      :periodic_time,
      :publisher,
      :related_url,
      :vouchered,
      # Biological Specimens only
      :idigbio_recordset_id,
      :idigbio_uuid,
      :is_type_specimen,
      :occurrence_id,
      :physical_object_type,
      :sex,
      # CHOs only
      :creator,
      :title
    ]

    # These show above the fold
    def primary_terms
      required_fields + [
        :bibliographic_citation,
        :catalog_number,
        :collection_code,
        :current_location,
        :date_created,
        :identifier,
        :institution,
        :related_url
      ]
    end

    # TODO make institution required for Biological Specimens, not required for CHOs
    # TODO make title required for CHOs, not for Biological Specimens
  end
end
