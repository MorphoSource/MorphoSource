module Morphosource
  class DetectorConfigurationService < QaSelectService
    def initialize(_authority_name = nil)
      super('detector_configuration')
    end
  end
end
