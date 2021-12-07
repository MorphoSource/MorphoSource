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
          collection.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
          collection
        end

        def import_gbif_slides
          json = get_gbif_json
          media = json["extensions"]["http://rs.tdwg.org/ac/terms/Multimedia"]
          @collection = slide_series_collection(json["scientificName"])
          media.each do |m|
            # every slide has two entries, best quality and thumbnail. 
            next if m["http://rs.tdwg.org/ac/terms/variantLiteral"] == "Best Quality"
            title = [m["http://purl.org/dc/terms/description"]] #["HEC-1009 Slide A"]
            description = [m["http://purl.org/dc/terms/description"]] #["HEC-1009 Slide A"]
            license = [m["http://ns.adobe.com/xap/1.0/rights/WebStatement"]] #["http://creativecommons.org/licences/by-nc-sa/3.0/"]
            publisher = [m["http://rs.tdwg.org/ac/terms/metadataProviderLiteral"]] #["Museum of Comparative Zoology, Harvard University"]
            rights_holder = [m["http://ns.adobe.com/xap/1.0/rights/Owner"]] #["Museum of Comparative Zoology, Harvard University"]
            @import_url = m["http://rs.tdwg.org/ac/terms/accessURI"].split.present? ?  m["http://rs.tdwg.org/ac/terms/accessURI"].split("/tiles/", 2).first : nil #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300"
            slide_atlas_url = @import_url.gsub('api/v1/','#') #"https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"
            related_url = [m["http://purl.org/dc/terms/identifier"], slide_atlas_url] #["http://mczbase.mcz.harvard.edu/media/1468742", "https://images.slide-atlas.org/#item/5c454d3c70aaa9064404a300"]
            identifier = [m["http://rs.tdwg.org/ac/terms/accessURI"][/\/item\/(.*?)\/tiles\//,1]] #["5c454d3c70aaa9064404a300"]
            @thumbnail_path = m["http://rs.tdwg.org/ac/terms/accessURI"].split("?").first #"https://images.slide-atlas.org/api/v1/item/5c454d3c70aaa9064404a300/tiles/thumbnail

            @media = Media.create(title: title, description: description, license: license, rights_holder: rights_holder, depositor: @manager.ms_id, publisher: publisher, media_type: ['Image'], import_url: @import_url, identifier: identifier, related_url: related_url, visibility: 'open', fileset_accessibility: ['open'])

            admin_user = User.find_by(email: 'admin@email.com')
            Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(Media.new, ::Ability.new(admin_user), @media.attributes))

            characterize_and_create_thumbnail

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

        def characterize_and_create_thumbnail
          make_derivative_directory
          characterize_file
          create_thumbnail
        end

        def characterize_file
          @file_uri = @import_url + '/download'
          copy_remote_file(@media.identifier.first + '_full')
          file_set = FileSet.create
          @media.ordered_members << file_set
          begin
            response = Faraday.head @file_uri
            name = response.headers["content-disposition"].match(/filename=(\"?)(.+)\1/)[2]
            file_set.title = [name]
            file_set.label = name
            text_file = Tempfile.new(name, encoding: 'ascii-8bit')
            Hydra::Works::AddFileToFileSet.call(file_set, text_file, :original_file, update_existing: true, versioning: true)

            CharacterizeNoDeriveJob.perform_now(file_set, file_set.original_file.id, @tempfile.path)
            file_set.save
          ensure
            @tempfile.close
            @tempfile.unlink
          end
        end

        # override Morphosource::CustomThumbnails create_thumbnail
        def create_thumbnail
          @file_uri = @thumbnail_path
          copy_remote_file(@media.identifier.first + '_thumbnail')
          create_derivative
          update_thumbnail_id
        end

        def custom_thumbnail
          OpenStruct.new(:path => @tempfile.path, :tempfile => @tempfile)
        end

        def copy_remote_file(name)
          @tempfile = Tempfile.new(name, encoding: 'ascii-8bit')
          write_file(@tempfile)
        end

        def write_file(f)
          retriever = BrowseEverything::Retriever.new
          uri_spec = ActiveSupport::HashWithIndifferentAccess.new(url: URI(@file_uri), headers: {})
          retriever.retrieve(uri_spec) do |chunk|
            f.write(chunk)
          end
          f.rewind
        end

    end
  end
end
