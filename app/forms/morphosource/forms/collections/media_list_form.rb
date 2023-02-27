module Morphosource
  module Forms
    module Collections
      # rubocop:disable Metrics/ClassLength
      class MediaListForm < ::Hyrax::Forms::CollectionForm

        self.model_class = ::MediaList

        self.single_valued_fields = [:title, :description]

        delegate :blacklight_config, to: Morphosource::Collections::MediaListsController

      end
    end
  end
end
