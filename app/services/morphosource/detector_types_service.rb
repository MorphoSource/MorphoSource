module Morphosource
  class DetectorTypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('detector_types')
    end
  end
end
