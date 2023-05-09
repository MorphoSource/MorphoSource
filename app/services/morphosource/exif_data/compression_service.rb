module Morphosource
  module ExifData
    class CompressionService < QaSelectService
      def initialize(_authority_name = nil)
        super('compression')
      end
    end
  end
end