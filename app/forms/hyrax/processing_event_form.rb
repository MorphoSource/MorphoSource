# Generated via
#  `rails generate hyrax:work ProcessingEvent`
module Hyrax
  # Generated form for ProcessingEvent
  class ProcessingEventForm < Hyrax::Forms::WorkForm

    include SingleValuedForm

    class_attribute :single_value_fields

    self.model_class = ::ProcessingEvent

    # terms to show up on the form
    # terms already included as part of Hyrax basic metadata are commented out
    self.terms +=
      [#creator,
      #:date_created,
      #:description,
      :software]

    self.terms -=
      [:based_near,
      :bibliographic_citation,
      :contributor,
      :identifier,
      :import_url,
      :keyword,
      :label,
      :language,
      :license,
      :part_of,
      :publisher,
      :related_url,
      :relative_path,
      :resource_type,
      :rights,
      :rights_statement,
      :subject,
      :source]

    self.single_valued_fields = [:title, :description, :date_created]

    self.required_fields = [:title]

    def primary_terms
      required_fields + [:creator, :date_created, :software, :description]
    end



  end
end
