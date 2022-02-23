module Morphosource
  module Import
    module SlideSeries
      module Slides
        module Mcz

          # bit_depth
          def file_bit_depth
            # []
          end

          # bits_per_sample
          def file_bits_per_sample
            # []
          end

          # color_format
          def file_color_format
            # []
          end

          # color_space
          def file_color_space
            # []
          end

          # compression
          def file_compression
            # []
          end

          # date_created
          def file_date_created
            @file_json["created"]
          end

          # description
          #["HEC-1009 Slide A"]
          def media_description
            [@slide_json["http://purl.org/dc/terms/description"]]
          end

          # file_id
          def image_file_id
            @item_json["largeImage"]["fileId"]
          end

          # file_name
          def name
            @file_json["name"]
          end

          # height
          def image_height
            @tiles_json["sizeY"]
          end

          # identifier
          #["5c454d3c70aaa9064404a300"]
          def media_identifier
            [@slide_json["http://rs.tdwg.org/ac/terms/accessURI"].partition('item/').last]
          end

          # levels
          def file_levels
            @tiles_json["levels"]
          end

          # license
          #["http://creativecommons.org/licences/by-nc-sa/3.0/"]
          def media_license
            [@slide_json["http://ns.adobe.com/xap/1.0/rights/WebStatement"]]
          end

          # magnification
          def file_magnification
            @tiles_json["magnification"]
          end

          # mime_type
          def file_mime_type
            @file_json["mimeType"]
          end

          # pixel_spacing
          def file_pixel_spacing
            [@slide.x_spacing + '\\' + @slide.y_spacing]
          end

          # publisher
          #["Museum of Comparative Zoology, Harvard University"]
          def media_publisher
            [@slide_json["http://rs.tdwg.org/ac/terms/metadataProviderLiteral"]]
          end

          # related_url
          #["http://mczbase.mcz.harvard.edu/media/1468742", "https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"]
          def media_related_url
            [@slide_json["http://purl.org/dc/terms/identifier"], slide_atlas_url]
          end

          # rights_holder
          #["Museum of Comparative Zoology, Harvard University"]
          def media_rights_holder
            [@slide_json["http://ns.adobe.com/xap/1.0/rights/Owner"]]
          end

          # size
          def file_size
            @file_json["size"]
          end

          # spacing_between_slices
          def file_spacing_between_slices
            # []
          end

          # title
          #["HEC-1009 Slide A"]
          def media_title
            [@slide_json["http://purl.org/dc/terms/description"]]
          end

          # unit
          def file_unit
            ["Mm"]
          end

          # width
          def image_width
            @tiles_json["sizeX"]
          end

          # x_spacing
          def file_x_spacing
            @tiles_json["mm_x"]
          end

          # y_spacing
          def file_y_spacing
            @tiles_json["mm_y"]
          end

          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300"
          def import_url
            @import_url = @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split.present? ?  @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("/tiles/", 2).first : nil
          end

          #"https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"
          def slide_atlas_url
            @import_url.gsub('api/v1/','#')
          end


          #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300/tiles/thumbnail
          def thumbnail_path
            @thumbnail_path ||= @slide_json["http://rs.tdwg.org/ac/terms/accessURI"].split("?").first
          end


          # def import_mcz_slides
          #   json = gbif_json
          #   slides = json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"]
          #   slides.each do |slide|
          #     next if m["http://rs.tdwg.org/ac/terms/variantLiteral"] == "Best Quality"
          #
          #     @media = Media.new
          #
          #     @media.title = title(slide)
          #     @media
          #     # every slide has two entries, best quality and thumbnail.
          #
          #   end
          # end

          def import_gbif_slides

            @collection = slide_series_collection(json["scientificName"])
            media.each do |m|


              @media = Media.create(title: title, description: description, license: license, rights_holder: rights_holder, depositor: @manager.ms_id, publisher: publisher, media_type: ['Image'], import_url: @import_url, identifier: identifier, related_url: related_url, visibility: 'open', fileset_accessibility: ['open'])

              characterize_and_create_thumbnail


              admin_user = User.find_by(email: 'admin@email.com')
              Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(Media.new, ::Ability.new(admin_user), @media.attributes))


              @media.member_of_collections += [@collection]
              Hyrax::PermissionTemplateApplicator.apply(@collection.permission_template).to(model: @media)
              @media.save!
            end
          end

          def gbif_json
            uri = "https://api.gbif.org/v1/occurrence/#{@resource_id}"
            response = RestClient.get uri
            JSON.parse(response.body)
          end
        end
      end
    end
  end
end
