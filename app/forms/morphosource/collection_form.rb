module Morphosource
  class CollectionForm < Hyrax::Forms::CollectionForm
    include SingleValuedForm

    class_attribute :single_value_fields

    self.terms = [:title, :description, :creator, :contributor, :based_near, :related_url]

    self.required_fields = [:title]

    self.single_valued_fields = [:title, :description]

    def primary_terms
      self.terms
    end

    def secondary_terms
      []
    end
  end
end