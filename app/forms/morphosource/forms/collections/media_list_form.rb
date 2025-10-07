module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class MediaListForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::MediaList

        self.terms += [:list_type, :doi]

        self.single_valued_fields = [:title, :description, :list_type, :doi]

        delegate :blacklight_config, to: Morphosource::Collections::MediaListsController

        # These show above the fold
        def primary_terms
          super + [:list_type, :doi]
        end

      end
    end
  end
end
