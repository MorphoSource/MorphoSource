module Morphosource
  module Import
    class SlideSeriesService

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
        slides.each do |slide_json|
          @slide = slide_class.new(slide_json)
          @media = create_new_media
          add_fileset_and_file
          characterize_file
          create_thumbnail
          add_to_series_collection
          apply_permissions_and_save
        end
      end

      def create_new_media
        Media.create(title: @slide.title,
                     short_description: @slide.short_description,
                     media_type: ["Image"],
                     license: @slide.license,
                     publisher: @slide.publisher,
                     rights_holder: @slide.rights_holder,
                     related_url: @slide.related_url,
                     identifier: @slide.identifier,
                     orientation: @slide.orientation,
                     depositor: @manager.ms_id,
                     slice_thickness: @slide.slice_thickness,
                     x_spacing: @slide.x_spacing,
                     y_spacing: @slide.y_spacing,
                     z_spacing: @slide.z_spacing,
                     slice_thickness: @slide.slice_thickness,
                     unit: @slide.unit,
                     visibility: @slide.visibility,
                     fileset_accessibility: @slide.fileset_accessibility,
                     preview_mode: ["Interactive/Embeddable"],
                     date_uploaded: Date.today)
      end

      def add_fileset_and_file
        name = @slide.file_name
        file_set = FileSet.create(title: [name], label: name)
        @media.ordered_members << file_set
        file = Tempfile.new(name)
        Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file, update_existing: true, versioning: true)
      end

      def characterize_file
        file = @media.file_sets.first.original_file
        @slide.file_characterization_methods.each do |method|
          file.send(method+'=', @slide.send(method))
        end
        file.save!
      end

      def add_to_series_collection
        @media.member_of_collections += [@collection]
        Hyrax::PermissionTemplateApplicator.apply(@collection.permission_template).to(model: @media)
      end

      def apply_permissions_and_save
        @media.save!
        InheritPermissionsJob.perform_later(@media)
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

        # override Morphosource::CustomThumbnails create_thumbnail
        def create_thumbnail
          copy_remote_file
          create_derivative
          update_thumbnail_id
        end

        def custom_thumbnail
          OpenStruct.new(:path => @tempfile.path, :tempfile => @tempfile)
        end

        def copy_remote_file
          name = @media.identifier.first + '_thumbnail'
          @tempfile = Tempfile.new(name, encoding: 'ascii-8bit')
          write_file
        end

        def write_file
          retriever = BrowseEverything::Retriever.new
          uri_spec = ActiveSupport::HashWithIndifferentAccess.new(url: URI(@slide.slide_thumbnail_path), headers: {})
          retriever.retrieve(uri_spec) do |chunk|
            @tempfile.write(chunk)
          end
          @tempfile.rewind
        end
    end
  end
end
