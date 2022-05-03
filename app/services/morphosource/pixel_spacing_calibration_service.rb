module Morphosource
  class PixelSpacingCalibrationService < QaSelectService
    def initialize(_authority_name = nil)
      super('pixel_spacing_calibration')
    end
  end
end
