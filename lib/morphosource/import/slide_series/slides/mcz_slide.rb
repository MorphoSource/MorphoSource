module Morphosource
  module Import
    module SlideSeries
      module Slides
        class MczSlide < Morphosource::Import::SlideSeries::Slides::Slide

          include Morphosource::Import::SlideSeries::Slides::Mcz

          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300/tiles/thumbnail
          def slide_thumbnail_path
            # @slide_thumbnail_path ||= @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("?").first
            tiles_uri + '/thumbnail'
          end

          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300"
          def import_url
            @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split.present? ?  @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("/tiles/", 2).first : nil
          end

          def external_file
            [import_url.concat("/download")]
          end

          private

            def gather_metadata
              @import_url = import_url
              @item_json = json(@import_url.gsub('#', 'api/v1/'))
              @slide_thumbnail_path = slide_thumbnail_path
              @file_json = json(file_uri)
              @tiles_json = json(tiles_uri)
            end

            def file_uri
              "https://images.slide-atlas.org/api/v1/file/#{image_file_id}"
            end

            def tiles_uri
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
