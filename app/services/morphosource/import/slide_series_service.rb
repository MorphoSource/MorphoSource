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

          @uri = URI(@thumbnail_path)
          name = @media.identifier.first
          copy_remote_file(name)


          create_derivative
          update_thumbnail_id
        end

        # def create_derivative
        #   # @uri = URI(@thumbnail_path)
        #   # name = @media.identifier.first
        #   # copy_remote_file(name)
        #   begin
        #     ::Morphosource::Derivatives::CroppedImageDerivatives.create(
        #       custom_thumbnail.path,
        #       outputs: [{
        #         label: :thumbnail,
        #         url: thumbnail_url,
        #       }]
        #     )
        #   ensure
        #     custom_thumbnail.tempfile.close
        #     custom_thumbnail.tempfile.unlink
        #   end
        # end

        def custom_thumbnail
          # @original_filename = "Help"
          # @content_type = "image/png"
          # @headers = {}
          # byebug
          # OpenStruct.new(:path => @pathpath, :tempfile => @tempfile, :original_filename => "Help", :content_type => "image/png", :headers=> {})
          OpenStruct.new(:path => @tempfile.path, :tempfile => @tempfile)
        end

        def copy_remote_file(name)
          # filename = File.basename(name)
          # byebug
          # dir = Dir.mktmpdir
          Rails.logger.debug("ImportUrlJob: Copying <#{@uri}>")


          # url =  http://s3.amazonaws.com/estock/fspid10/27/40/27/6/buddhism-hindu-religion-2740276-o.png
          # tmp_file = Tempfile.new([name, '.jpg'])
          # tmp_file.binmode
          #
          # open(url) do |url_file|
          #   tmp_file.write(url_file.read)
          # end
          #
          # tmp_file.rewind
          #
          # tmp_file.read


          @tempfile = Tempfile.new(name, encoding: 'ascii-8bit')
            # byebug
            # begin
              # write_file(f)
              write_file(@tempfile)
              # @tempfile = f
              # yield f
            # rescue StandardError => e
              # send_error(e.message)
            # end
          # end
          # byebug
          # @pathpath = File.join(dir, filename)
          # byebug
          # return file
          # Rails.logger.debug("ImportUrlJob: Closing #{File.join(dir, filename)}")
        end

        def write_file(f)
          retriever = BrowseEverything::Retriever.new
          uri_spec = ActiveSupport::HashWithIndifferentAccess.new(url: @uri, headers: {})
          retriever.retrieve(uri_spec) do |chunk|
            f.write(chunk)
          end
          f.rewind
        end

    end
  end
end
