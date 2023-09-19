module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class OrganizationForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::OrganizationCollection

        self.single_valued_fields = [:title, :description]

        delegate :blacklight_config, to: Morphosource::Collections::OrganizationCollectionsController

      end
    end
  end
end