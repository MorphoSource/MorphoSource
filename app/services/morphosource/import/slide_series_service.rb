module Morphosource
  module Import
    class SlideSeriesService

      include Morphosource::CustomThumbnails

      def initialize(service, resource_id, user_email)
        @service = service
        @resource_id = resource_id
        @manager = User.find_by(email: user_email)
      end

      def call
        if @service == "GBIF"
          import_gbif_slides
        end
        @collection
      end

      private

        def slide_series_collection(title)
          project_collection_type = Hyrax::CollectionType.where(title: "Project").first
          collection = Collection.create(title: [title], collection_type_gid: project_collection_type.gid, depositor: @manager.ms_id, visibility: 'open')
          collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
          collection
        end

        #{"type"=>"StillImage", "format"=>"text/html", "title"=>"MCZ:SC:1405 Squalus acanthias", "description"=>"HEC-1009 Slide A", "publisher"=>"Museum of Comparative Zoology, Harvard University", "license"=>"http://creativecommons.org/licenses/by-nc-sa/3.0/", "rightsHolder"=>"Museum of Comparative Zoology, Harvard University", "identifier"=>"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300/tiles/thumbnail?width=160&height=100"}

        def import_gbif_slides
          json = get_gbif_json
          media = json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"]
          @collection = slide_series_collection(json["scientificName"])
          media.each do |m|
            byebug
            next if m["http://rs.tdwg.org/ac/terms/variantLiteral"] == "Best Quality"

            title = [m["http://purl.org/dc/terms/description"]]
            description = [m["http://purl.org/dc/terms/description"]]
            license = [m["http://ns.adobe.com/xap/1.0/rights/WebStatement"]]
            publisher = [m["http://rs.tdwg.org/ac/terms/metadataProviderLiteral"]]
            rights_holder = [m["http://ns.adobe.com/xap/1.0/rights/Owner"]]
            related_url = [m["http://purl.org/dc/terms/identifier"]]
            identifier = [m["http://rs.tdwg.org/ac/terms/accessURI"][/\/item\/(.*?)\/tiles\//,1]]
            import_url = m["http://rs.tdwg.org/ac/terms/accessURI"].split.present? ?  m["http://rs.tdwg.org/ac/terms/accessURI"].split("/tiles/", 2).first : nil
            @thumbnail_path = m["http://rs.tdwg.org/ac/terms/accessURI"].split("?").first
            # thumbnail_id = import_url.concat("/tiles/thumbnail")
            byebug
            @media = Media.create(title: title, description: description, license: license, rights_holder: rights_holder, depositor: @manager.ms_id, publisher: publisher, media_type: ['SlideImageSeries'], import_url: import_url, identifier: identifier, related_url: related_url, visibility: 'open', fileset_accessibility: ['open'])


            admin_user = User.find_by(email: 'admin@email.com')
            Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(Media.new, ::Ability.new(admin_user), @media.attributes))

            create_thumbnail

            @media.member_of_collections += [@collection]
            Hyrax::PermissionTemplateApplicator.apply(@collection.permission_template).to(model: @media)
            @media.save!
          end
        end

        def get_gbif_json
          uri = "https://api.gbif.org/v1/occurrence/#{@resource_id}"
          response = RestClient.get uri
          JSON.parse(response.body)
        end

        def create_thumbnail
          make_derivative_directory
          create_derivative
          update_thumbnail_id
        end

        def create_derivative
          # begin
            byebug
            ::Morphosource::Derivatives::CroppedImageDerivatives.create(
              custom_thumbnail.path,
              outputs: [{
                label: :thumbnail,
                url: thumbnail_url,
              }]
            )
          # ensure
            # byebug
            # custom_thumbnail.tempfile.close
            # custom_thumbnail.tempfile.unlink
          # end
        end

        def custom_thumbnail
          OpenStruct.new(:path => @thumbnail_path)
        end
    end
  end
end
