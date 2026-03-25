module Morphosource
  module ValkyrieWorkBehavior
    extend ActiveSupport::Concern

    included do
      include Hyrax::ArResource
      include Morphosource::ArResource
      include Morphosource::ArResourceMembership

      attr_accessor :skip_index_related_works
    end
  end
end