module Morphosource
  module Forms
    module Collections
      module MediaLists
        class SequentialSectionListForm < ::Morphosource::Forms::Collections::MediaListForm
          include SingleValuedForm

          class_attribute :single_valued_fields

          self.model_class = ::SequentialSectionList

          self.terms -= [:list_type]

          self.required_fields -= [:list_type]

          self.single_valued_fields = [:title, :description]

          delegate :blacklight_config, to: Morphosource::Collections::MediaLists::SequentialSectionListsController

          # These show above the fold
          def primary_terms
            super - [:list_type]
          end

        end
      end
    end
  end
end