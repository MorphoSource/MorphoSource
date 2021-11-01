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

        def import_gbif_slides
          json = get_gbif_json
          media = json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"]
          @collection = slide_series_collection(json["scientificName"])
          media.each do |m|
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

            @media = Media.create(title: title, description: description, license: license, rights_holder: rights_holder, depositor: @manager.ms_id, publisher: publisher, media_type: ['Image'], import_url: import_url, identifier: identifier, related_url: related_url, visibility: 'open', fileset_accessibility: ['open'])

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

        # override Morphosource::CustomThumbnails create_thumbnail
        def create_thumbnail
          # @uri = URI(@thumbnail_path)

          make_derivative_directory
          copy_remote_file(@media.identifier.first)
          create_derivative
          update_thumbnail_id
        end

        def custom_thumbnail
          OpenStruct.new(:path => @tempfile.path, :tempfile => @tempfile)
        end

        def copy_remote_file(name)
          Rails.logger.debug("ImportUrlJob: Copying <#{@uri}>")

          @tempfile = Tempfile.new(name, encoding: 'ascii-8bit')
          write_file(@tempfile)
        end

        def write_file(f)
          retriever = BrowseEverything::Retriever.new
          uri_spec = ActiveSupport::HashWithIndifferentAccess.new(url: URI(@thumbnail_path), headers: {})
          retriever.retrieve(uri_spec) do |chunk|
            f.write(chunk)
          end
          f.rewind
        end

    end
  end
end
