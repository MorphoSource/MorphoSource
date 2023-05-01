module Morphosource
  module Import
    module SlideSeries
      module Slides
        class MczSlide < Morphosource::Import::SlideSeries::Slides::Slide

          include Morphosource::Import::SlideSeries::Slides::Mcz

          def slide_thumbnail_path
            iiif_base_uri.concat('/full/200,/0/default.jpg')
          end

          def import_url
            # @slide_json["http://rs.tdwg.org/ac/terms/accessURI"]
            # "https://iiif.mcz.harvard.edu/iiif/3/3816312/full/1000,/0/default.jpg"
            # "https://ids.lib.harvard.edu/ids/iiif/47174896/full/max/0/default.jpg"
            # "https://iiif.mcz.harvard.edu/iiif/3/3823276/full/1000,/0/default.jpg"
            # iiif_base_uri.concat('/full/5000,/0/default.jpg')
            "https://iiif.mcz.harvard.edu/iiif/3/3823276/full/2000,/0/default.jpg"
          end

          # mcz server is not delivering full size images right now, fix this later.
          # file set should be able to use import_url.
          def reduced_size_url
            # iiif_base_uri.concat('/full/1000,/0/default.jpg')
            "https://iiif.mcz.harvard.edu/iiif/3/3823276/full/2000,/0/default.jpg"
          end


          private

            def gather_metadata
              @import_url = import_url
              @iiif_json = iiif_json
              @iiif_exif = iiif_exif
              @slide_thumbnail_path = slide_thumbnail_path
            end

            def iiif_base_uri
              import_url.split('/full/').first
              # @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split('/full/').first
            end

            def iiif_json
              json(iiif_base_uri.concat('/info.json'))
            end

            def iiif_exif
              @iiif_json["exif"]
            end

        end
      end
    end
  end
end
