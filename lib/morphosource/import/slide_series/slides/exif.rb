module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Exif

          # bits_per_sample
          def bits_per_sample(source)
            @iiif_exif.dig("fields","BitsPerSample") || super
          end

        end
      end
    end
  end
end
