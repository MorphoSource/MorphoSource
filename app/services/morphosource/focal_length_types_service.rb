module Morphosource
  class FocalLengthTypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('focal_length_types')
    end
  end
end
