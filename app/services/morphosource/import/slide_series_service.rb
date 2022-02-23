module Morphosource
  module Import
    class SlideSeriesService

      # include Morphosource::Import::Slides::Mcz
      include Morphosource::CustomThumbnails

      def self.call(service, resource_id, user_email)
        self.new(service, resource_id, user_email).call
      end

      def initialize(service, resource_id, user_email)
        @service = service
        @resource_id = resource_id
        @manager = User.find_by(email: user_email)
      end

      def call
        import_slide_series
        @collection
      end

      def import_slide_series
        fetch_json
        create_series_collection(collection_title)
        import_slides
      end

      def import_slides
        slides.each do |slide|
          @slide = slide_class.new(slide)
          create_new_media
          byebug
          add_fileset_and_file
          characterize_file
          create_thumbnail
          add_to_series_collection
        end
      end

      def create_new_media
        @media = Media.create(title: @slide.title,
                              description: @slide.description,
                              license: @slide.license,
                              publisher: @slide.publisher,
                              rights_holder: @slide.rights_holder,
                              related_url: @slide.related_url,
                              identifier: @slide.identifier,
                              depositor: @manager.ms_id,
                              slice_thickness: @slide.slice_thickness,
                              unit: @slide.unit
                            )
      end

      def add_fileset_and_file
        name = @slide.file_name
        file_set.title = [name]
        file_set.label = name
        file = Tempfile.new(name)
        Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file, update_existing: true, versioning: true)
      end

      def characterize_file
        file = @media.file_sets.first.original_file

        file.mime_type = @slide.mime_type
        file.file_name = [@slide.file_name]
        file.original_file = @slide.file_name
        file.size = @slide.file_size
        file.width = @slide.width
        file.height = @slide.height
        file.bit_depth = []
        file.compression = []
        file.color_space = []
        file.color_format = []
        file.bits_per_sample = []
        file.pixel_spacing = [@slide.x_spacing + '\\' + @slide.y_spacing]
        file.spacing_between_slices = []
      end

      def create_thumbnail
      end

      def add_to_series_collection
      end



      private

        def create_series_collection(title)
          project_collection_type = Hyrax::CollectionType.where(title: "Project").first
          @collection = Collection.create(title: [title], collection_type_gid: project_collection_type.gid, depositor: @manager.ms_id, visibility: 'open')
          @collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: @collection)
          @collection.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
          @collection
        end

        # def characterize_and_create_thumbnail
        #   make_derivative_directory
        #   characterize_file
        #   create_thumbnail
        # end

        # jpeg characterization: {:fits_version=>["1.5.0"], :format_label=>["JPEG File Interchange Format"], :file_mime_type=>["image/jpeg"], :exif_tool_version=>["11.54"], :file_size=>["15636"], :filename=>["5915e543dd98b578723a0a15_full20220114-4369-2yuzl6"], :original_checksum=>["5b286b54b616e195c17ddf49450a9f23"], :well_formed=>["true"], :valid=>["true"], :byte_order=>["big endian"], :bits_per_sample=>["8 8 8"], :compression=>["JPEG"], :width=>["230"], :height=>["420"], :color_space=>["YCbCr"]}

        # {"name"=>"/tmp/5915e543dd98b578723a0a15_full20220114-3993-1g7oet5[0]", "format"=>"TIFF64", "formatDescription"=>"Tagged Image File Format (64-bit)", "mimeType"=>"image/tiff", "class"=>"DirectClass", "geometry"=>{"width"=>21572, "height"=>18331, "x"=>0, "y"=>0}, "resolution"=>{"x"=>"10000", "y"=>"10000"}, "printSize"=>{"x"=>"2.1572000000000000064", "y"=>"1.8330999999999999517"}, "units"=>"PixelsPerCentimeter", "type"=>"TrueColor", "baseType"=>"TrueColor", "endianess"=>"Undefined", "colorspace"=>"sRGB", "depth"=>8, "baseDepth"=>8, "channelDepth"=>{"red"=>8, "green"=>8, "blue"=>8}, "pixels"=>395436332, "imageStatistics"=>{"all"=>{"min"=>"0", "max"=>"255", "mean"=>"17.4812", "standardDeviation"=>"49.5345", "kurtosis"=>"11.905", "skewness"=>"3.55804"}}, "channelStatistics"=>{"red"=>{"min"=>"0", "max"=>"255", "mean"=>"19.753", "standardDeviation"=>"54.6486", "kurtosis"=>"9.57478", "skewness"=>"3.26406"}, "green"=>{"min"=>"0", "max"=>"255", "mean"=>"17.4575", "standardDeviation"=>"48.3282", "kurtosis"=>"12.2609", "skewness"=>"3.57759"}, "blue"=>{"min"=>"0", "max"=>"252", "mean"=>"15.2331", "standardDeviation"=>"45.1543", "kurtosis"=>"14.3268", "skewness"=>"3.84907"}}, "renderingIntent"=>"Perceptual", "gamma"=>0.454545, "chromaticity"=>{"redPrimary"=>{"x"=>0.64, "y"=>0.33}, "greenPrimary"=>{"x"=>0.3, "y"=>0.6}, "bluePrimary"=>{"x"=>0.15, "y"=>0.06}, "whitePrimary"=>{"x"=>0.3127, "y"=>0.329}}, "backgroundColor"=>"#FFFFFF", "borderColor"=>"#DFDFDF", "matteColor"=>"#BDBDBD", "transparentColor"=>"#000000", "interlace"=>"None", "intensity"=>"Undefined", "compose"=>"Over", "pageGeometry"=>{"width"=>21572, "height"=>18331, "x"=>0, "y"=>0}, "dispose"=>"Undefined", "iterations"=>0, "compression"=>"JPEG", "orientation"=>"TopLeft", "properties"=>{"comment"=>"Scan Size = 21.57x18.33 mm\nImage Dimensions = 21572x18331 Pixels\nResolution = 1.00 um\nSource = Bright Field\nScan Started = 2019:10:15 18:08:23\nScan Duration = 00:03:50\nCompress Option = JPEG\nCompress Method = Lossy\nImage Quality = 0.900000\n", "date:create"=>"2022-01-14T17:37:21+00:00", "date:modify"=>"2022-01-14T17:37:21+00:00", "signature"=>"7c270af7560109c72f7097d9e0ece1efcae8f4fb4dd93b14224a99de1f700f12", "tiff:alpha"=>"unspecified", "tiff:endian"=>"lsb", "tiff:make"=>"Huron Digital Pathology", "tiff:model"=>"TissueScope LE 120", "tiff:photometric"=>"YCBCR", "tiff:software"=>"MACROscan 1.32", "tiff:subfiletype"=>"PAGE", "tiff:timestamp"=>"2019:10:15 18:08:23"}, "artifacts"=>{"filename"=>"/tmp/5915e543dd98b578723a0a15_full20220114-3993-1g7oet5[0]"}, "tainted"=>false, "filesize"=>"27.32MB", "numberPixels"=>"395.4M", "pixelsPerSecond"=>"81.7MB", "userTime"=>"4.040u", "elapsedTime"=>"0:05.839", "version"=>"ImageMagick 6.9.7-4 Q16 x86_64 20170114 http://www.imagemagick.org"}




        def characterize_file
          @characterization = OpenStruct.new

          get_item_values
          get_file_values
          get_tile_values
          get_template_values


          byebug





          byebug
          file_set = FileSet.create
          @media.ordered_members << file_set

            name = @characterization.file_name
            file_set.title = [name]
            file_set.label = name
            text_file = Tempfile.new(name)
            Hydra::Works::AddFileToFileSet.call(file_set, text_file, :original_file, update_existing: true, versioning: true)


            file = file_set.original_file

            file.mime_type = @characterization.mime_type
            file.file_name = [@characterization.file_name]
            file.original_file = @characterization.file_name
            file.size = @characterization.file_size
            file.width = @characterization.width
            file.height = @characterization.height
            file.bit_depth = []
            file.compression = []
            file.color_space = []
            file.color_format = []
            file.bits_per_sample = []
            file.pixel_spacing = [@characterization.x_spacing + '\\' + @characterization.y_spacing]
            file.spacing_between_slices = []

            @media.slice_thickness = []
            @media.unit = ["Mm"]



            #  file.bit_depth
            #  => []
            #  file.compression
            #  => ["JPEG"]
            #  2.6.6 :058 > file.color_space
            #  => ["YCbCr"]
            #  file.color_format
            #  => []
            #
            #  # color_depth
            #  2.6.6 :061 > file.bits_per_sample
            #  => ["8 8 8"]
            #

            # #  = z pixel spacing
            #   2.6.6 :070 > file.spacing_between_slices
            #  => ["0.58975"]
            #
            #  2.6.6 :074 > media.slice_thickness
            #  => ["17"]
            #


            file_set.save

        end

        # Hydra::Works::AddFileToFileSet.call(f, a, :original_file, update_existing: true, versioning: true)

        # def characterize_file
        #   # @file_uri = @import_url + '/download'
        #   @file_uri = "https://images.slide-atlas.org/api/v1/file/5a5f89e41fbb906b49446ddf/download"
        #   byebug
        #   copy_remote_file(@media.identifier.first + '_full')
        #   byebug
        #   file_set = FileSet.create
        #   @media.ordered_members << file_set
        #   begin
        #     response = Faraday.head @file_uri
        #     name = response.headers["content-disposition"].match(/filename=(\"?)(.+)\1/)[2]
        #     file_set.title = [name]
        #     file_set.label = name
        #     text_file = Tempfile.new(name, encoding: 'ascii-8bit')
        #     Hydra::Works::AddFileToFileSet.call(file_set, text_file, :original_file, update_existing: true, versioning: true)
        #
        #     CharacterizeNoDeriveJob.perform_now(file_set, file_set.original_file.id, @tempfile.path)
        #     byebug
        #     file_set.save
        #   ensure
        #     @tempfile.close
        #     @tempfile.unlink
        #   end
        # end

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


# file.file_name => ["Tray1-1-48_2_S05_Rescan01.tif"]
# file.original_name => "Tray1-1-48_2_S05_Rescan01.tif"
# file.mime_type
#  => "image/x-tiff-big"
#  file.size
#  => 1537040168
#  2.6.6 :048 > file.size
#  => 1537040168
# 2.6.6 :049 > file.width
#  => ["420"]
# 2.6.6 :050 > file.height
#  => ["550"]
#  # = y_spacing \\ x_spacing
#  2.6.6 :068 > file.pixel_spacing
#   => ["0.592047\\0.59091"]
#  2.6.6 :079 > m.unit
#  => ["Um"]
