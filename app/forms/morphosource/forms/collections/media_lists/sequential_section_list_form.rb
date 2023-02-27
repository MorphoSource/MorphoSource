module Morphosource
  module Forms
    module Collections
      module MediaLists
        class SequentialSectionListForm < ::Morphosource::Forms::Collections::MediaListForm
          include SingleValuedForm

          class_attribute :single_valued_fields

          self.model_class = ::SequentialSectionList

          self.single_valued_fields = [:title, :description]

          delegate :blacklight_config, to: Morphosource::Collections::MediaLists::SequentialSectionListsController
        end
      end
    end
  end
end