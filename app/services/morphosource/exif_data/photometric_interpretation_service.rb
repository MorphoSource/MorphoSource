# https://exiftool.org/TagNames/EXIF.html
module Morphosource
  module ExifData
    class PhotometricInterpretationService < QaSelectService
      def initialize(_authority_name = nil)
        super('photometric_interpretation')
      end
    end
  end
end