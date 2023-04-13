module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Mcz

          # define organization/specific individual slide values here
          # overrides defaults defined in Morphosource::Import::SlideSeries::Slides::Slide

          # bits_per_sample
          def bits_per_sample
            # byebug
            @iiif_exif["fields"]["BitsPerSample"]
          end

          # color_space
          # See https://exiftool.org/TagNames/EXIF.html for values
          def color_space
            ExifData::PHOTOMETRIC_INTERPRETATION[@iiif_exif["fields"]["PhotometricInterpretation"]] || []
          end

          # compression
          # See https://exiftool.org/TagNames/EXIF.html#Compression
          def compression
            ExifData::COMPRESSION[@iiif_exif["fields"]["Compression"]] || []
          end

          # file.create_date
          # date_created
          def date_created
            # byebug
            [Date.parse(@iiif_exif['fields']["DateTime"].split(' ').first.gsub(':','-')).strftime("%Y-%m-%d")]
            # [Date.parse(@file_json["created"]).strftime("%Y-%m-%d")]
          end

          # date_modified
          # ["2018:12:17 17:03:34"]
          def date_modified
            # byebug
            # @item_json["updated"]
            []
          end

          def description
            # byebug
            [JSON.parse(@slide_json["http://rs.tdwg.org/dwc/terms/preparations"]).map{|k,v| k.dup.concat(': ').concat(v)}.join(', ')]
            # if @json["preparations"].present? &&  @json["identificationRemarks"].present?
            #   [@json["preparations"] + ' | ' + @json["identificationRemarks"]]
            # elsif @json["preparations"].present?
            #   [@json["preparations"]]
            # elsif @json["identificationRemarks"].present?
            #   [@json["identificationRemarks"]]
            # else
            #   []
            # end
          end

          # file_name
          def file_name
            # byebug
            @iiif_json["originalFilename"]
          end

          # file_size
          def file_size
            # byebug
            # [@file_json["size"].to_s]
            @iiif_json["fileSize"]
          end

          def fileset_accessibility
            ["open"]
          end

          # height
          def height
            # byebug
            @iiif_json["height"].to_s
            # @tiles_json["sizeY"].to_s
          end

          # identifier
          #["5c454d3c70aaa9064404a300"]
          def identifier
            # byebug
            # [@slide_json["http://rs.tdwg.org/ac/terms/accessURI"][/\/item\/(.*?)\/tiles\//,1]]
            # Array(@import_url.split('/#item/').last)
            Array(iiif_base_uri.split('/').last)
          end

          def imaging_description
            # byebug
            Array(@iiif_exif["fields"]["ImageDescription"])
          end

          # license
          #["http://creativecommons.org/licences/by-nc-sa/3.0/"]
          def license
            # byebug
            [@slide_json["http://ns.adobe.com/xap/1.0/rights/WebStatement"]]
          end

          def file_magnification
            byebug
            @tiles_json["magnification"]
          end

          # mime_type
          def mime_type
            [@slide_json["http://purl.org/dc/elements/1.1/format"]]
            # @file_json["mimeType"]
          end

          # pixel_spacing
          def pixel_spacing
            # byebug
            # [@tiles_json["mm_x"].to_s + '\\' + @tiles_json["mm_y"].to_s]
            [x_spacing.first + '\\' + y_spacing.first]
          end

          # publisher
          #["Museum of Comparative Zoology, Harvard University"]
          def publisher
            # byebug
            [@slide_json["http://rs.tdwg.org/ac/terms/metadataProviderLiteral"]]
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742", "https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"]
          def related_url
            # byebug
            [@slide_json["http://purl.org/dc/terms/identifier"]]
          end

          # rights_holder
          #["Museum of Comparative Zoology, Harvard University"]
          def rights_holder
            # byebug
            [@slide_json["http://rs.tdwg.org/ac/terms/providerLiteral"]]
          end

          def scanning_software
            # byebug
            Array(@iiif_exif['fields']["Software"])
            # scan_date = Date.parse(date_created.first)
            # if scan_date < Date.parse('2018-04-24')
            #   ["MACROscan 1.26"]
            # elsif scan_date < Date.parse('2018-08-01')
            #   ["MACROscan 1.28"]
            # elsif scan_date < Date.parse('2019-02-16')
            #   ["MACROscan 1.31"]
            # else
            #   ["MACROscan 1.32"]
            # end
          end

          # short_description
          #["HEC-1009 Slide A"]
          def short_description
            # byebug
            [@slide_json["http://purl.org/dc/terms/description"]]
          end

          # title
          #["HEC-1009 Slide A [Image]"]
          def title
            Array(short_description.first + " [Image]")
          end

          # unit
          def unit
            ExifData::RESOLUTION_UNIT[@iiif_exif["ResolutionUnit"]] || []
          end

          def visibility
            'open'
          end

          # width
          def width
            # byebug
            @iiif_json["width"].to_s
          end

          # x_spacing
          def x_spacing
            # byebug
            # [@tiles_json["mm_x"].to_s]
            d = @iiif_exif['fields']["XResolution"]["denominator"].to_f
            n = @iiif_exif['fields']["XResolution"]["numerator"].to_f
            ["%f" % (d/n)]
          end

          # y_spacing
          def y_spacing
            d = @iiif_exif['fields']["YResolution"]["denominator"].to_f
            n = @iiif_exif['fields']["YResolution"]["numerator"].to_f
            ["%f" % (d/n)]
          end
        end
      end
    end
  end
end
