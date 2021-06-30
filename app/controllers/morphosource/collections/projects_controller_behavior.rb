module Morphosource
  module Collections
    module ProjectsControllerBehavior
      extend ActiveSupport::Concern
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base

      include Morphosource::CollectionsControllerBehavior

      included do
        self.presenter_class = Morphosource::ProjectPresenter
      end

    end
  end
end
