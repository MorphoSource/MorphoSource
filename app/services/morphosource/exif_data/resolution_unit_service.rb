# https://exiftool.org/TagNames/EXIF.html
module Morphosource
  module ExifData
    class ResolutionUnitService < QaSelectService
      def initialize(_authority_name = nil)
        super('resolution_unit')
      end
    end
  end
end