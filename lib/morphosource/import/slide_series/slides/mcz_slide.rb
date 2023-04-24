module Morphosource
  module Import
    module SlideSeries
      module Slides
        class MczSlide < Morphosource::Import::SlideSeries::Slides::Slide

          include Morphosource::Import::SlideSeries::Slides::Mcz

          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300/tiles/thumbnail
          def slide_thumbnail_path
            # byebug
            # @slide_thumbnail_path ||= @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("?").first
            # tiles_uri + '/thumbnail'
            iiif_base_uri.concat('/full/200,/0/default.jpg')
          end

          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300"
          def import_url
            # byebug
            # @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split.present? ?  @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("/tiles/", 2).first : nil

            # @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].present? ? @slide_json["http://rs.tdwg.org/ac/terms/accessURI"] : nil
            "https://iiif.mcz.harvard.edu/iiif/3/1485160/full/200,/0/default.jpg"
          end

          def external_file
            # byebug
            # [import_url.concat("/download")]
            file_uri
          end

          private

            def gather_metadata
              @import_url = import_url
              # @item_json = json(@import_url.gsub('#', 'api/v1/'))
              @iiif_json = json(iiif_json)
              # byebug
              @iiif_exif = iiif_exif
              @slide_thumbnail_path = slide_thumbnail_path
              # @file_json = json(file_uri)
              # @tiles_json = json(tiles_uri)
            end

            def iiif_base_uri
              file_uri.split('/full/').first
            end

            def iiif_json
              iiif_base_uri.concat('/info.json')
            end

            def iiif_exif
              @iiif_json["exif"]
            end

            def file_uri
              # byebug
              # "https://images.slide-atlas.org/api/v1/file/#{image_file_id}"
              @slide_json["http://rs.tdwg.org/ac/terms/accessURI"]
            end

            def tiles_uri
              # byebug
              @import_url.gsub('#', 'api/v1/') + "/tiles"
            end

            # file_id
            def image_file_id
              @item_json["largeImage"]["fileId"]
            end

            #"https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"
            def slide_atlas_url
              # @import_url.gsub('api/v1/','#')
              @import_url
            end

        end
      end
    end
  end
end
