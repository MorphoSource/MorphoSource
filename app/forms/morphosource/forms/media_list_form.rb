module Morphosource
  module Forms
    # rubocop:disable Metrics/ClassLength
    class MediaListForm < ::Hyrax::Forms::CollectionForm

      self.model_class = ::MediaList

      delegate :blacklight_config, to: Morphosource::Collections::MediaListsController

    end
  end
end
