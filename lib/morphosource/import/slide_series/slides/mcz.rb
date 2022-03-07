module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Mcz

          # define organization/specific values here
          # overrides defaults defined in Morphosource::Import::SlideSeries::Slides::Slide

          # bits_per_sample
          def bits_per_sample
            ["8 8 8"]
          end

          # color_space
          def color_space
            ["YCbCr"]
          end

          # compression
          def compression
            ["JPEG"]
          end

          # file.create_date
          # date_created
          def date_created
            [Date.parse(@file_json["created"]).strftime("%Y-%m-%d")]
          end

          # date_modified
          # ["2018:12:17 17:03:34"]
          def date_modified
            @item_json["updated"]
          end

          def description
            if @json["preparations"].present? &&  @json["identificationRemarks"].present?
              [@json["preparations"] + ' | ' + @json["identificationRemarks"]]
            elsif @json["preparations"].present?
              [@json["preparations"]]
            elsif @json["identificationRemarks"].present?
              [@json["identificationRemarks"]]
            else
              []
            end
          end

          # file_name
          def file_name
            @file_json["name"]
          end

          def fileset_accessibility
            ["open"]
          end

          # height
          def height
            @tiles_json["sizeY"].to_s
          end

          # identifier
          #["5c454d3c70aaa9064404a300"]
          def identifier
            [@slide_json["http://rs.tdwg.org/ac/terms/accessURI"][/\/item\/(.*?)\/tiles\//,1]]
          end

          # license
          #["http://creativecommons.org/licences/by-nc-sa/3.0/"]
          def license
            [@slide_json["http://ns.adobe.com/xap/1.0/rights/WebStatement"]]
          end

          def file_magnification
            @tiles_json["magnification"]
          end

          # mime_type
          def mime_type
            @file_json["mimeType"]
          end

          # pixel_spacing
          def pixel_spacing
            [@tiles_json["mm_x"].to_s + '\\' + @tiles_json["mm_y"].to_s]
          end

          # publisher
          #["Museum of Comparative Zoology, Harvard University"]
          def publisher
            [@slide_json["http://rs.tdwg.org/ac/terms/metadataProviderLiteral"]]
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742", "https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"]
          def related_url
            [@slide_json["http://purl.org/dc/terms/identifier"], slide_atlas_url]
          end

          # rights_holder
          #["Museum of Comparative Zoology, Harvard University"]
          def rights_holder
            [@slide_json["http://ns.adobe.com/xap/1.0/rights/Owner"]]
          end

          # file_size
          def file_size
            [@file_json["size"].to_s]
          end

          def scanning_software
            scan_date = Date.parse(date_created.first)
            if scan_date < Date.parse('2018-04-24')
              ["MACROscan 1.26"]
            elsif scan_date < Date.parse('2018-08-01')
              ["MACROscan 1.28"]
            elsif scan_date < Date.parse('2019-02-16')
              ["MACROscan 1.31"]
            else
              ["MACROscan 1.32"]
            end
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            [@slide_json["http://purl.org/dc/terms/description"]]
          end

          # title
          #["HEC-1009 Slide A [Image]"]
          def title
            [@slide_json["http://purl.org/dc/terms/description"] + " [Image]"]
          end

          # unit
          def unit
            ["Mm"]
          end

          def visibility
            'open'
          end

          # width
          def width
            @tiles_json["sizeX"].to_s
          end

          # x_spacing
          def x_spacing
            [@tiles_json["mm_x"].to_s]
          end

          # y_spacing
          def y_spacing
            [@tiles_json["mm_y"].to_s]
          end
        end
      end
    end
  end
end
