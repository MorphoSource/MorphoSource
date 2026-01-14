module Morphosource
  # Functionality that should be applied to all Valkyrie forms goes here
  module ValkyrieFormBehavior
    extend ActiveSupport::Concern

    included do
      property :id
      property :skip_index_related_works
    end
  end
end