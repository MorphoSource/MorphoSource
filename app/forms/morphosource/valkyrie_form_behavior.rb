module Morphosource
  module ValkyrieFormBehavior
    extend ActiveSupport::Concern

    included do
      property :id
    end
  end
end