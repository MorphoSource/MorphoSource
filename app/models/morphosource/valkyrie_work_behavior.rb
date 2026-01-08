module Morphosource
  module ValkyrieWorkBehavior
    extend ActiveSupport::Concern

    included do
      attr_accessor :skip_index_related_works
    end
  end
end