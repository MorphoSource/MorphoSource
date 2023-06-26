module Morphosource
  module Import
    module SlideSeries
      module Slides
        class MczSlide < Morphosource::Import::SlideSeries::Slides::Slide

          include Morphosource::Import::SlideSeries::Slides::Mcz

          private

            def gather_metadata
              @iiif_json = iiif_json
              @iiif_exif = iiif_exif
            end

            def iiif_base_uri
              @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split('/full/').first
            end

            def iiif_json
              json("#{iiif_base_uri}/info.json")
            end

            def iiif_exif
              @iiif_json["exif"]
            end
        end
      end
    end
  end
end