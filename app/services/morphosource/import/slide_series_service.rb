module Morphosource
  module Import
    class SlideSeriesService

      include Morphosource::CustomThumbnails

      def self.call(service: nil, resource_id: nil, user_email: nil, list_visibility: 'restricted')
        self.new(service, resource_id, user_email, list_visibility).call
      end

      def initialize(service: nil, resource_id: nil, user_email: nil, list_visibility: 'restricted')
        @organization = organization
        @service = service
        @resource_id = resource_id
        @manager = User.find_by(email: user_email)
        @admin = User.find_by(ms_id: Hyrax.config.batch_user_key)
        @list_visibility = list_visibility
      end

      # This will get refactored with providers yml PR
      def call
        @json = fetch_json
        return @json if @json.is_a? String # error message returned

        import_slide_series
        @collection
      end

      def import_slide_series
        @specimen = find_or_create_specimen
        @taxonomy = @specimen.taxonomies.first
        @device = device
        @collection = create_series_collection
        import_slides
      end

      def import_slides
        Hyrax.config.index_related_works = false
        slides.each do |slide_json|
          @slide = slide_class.new(@json, slide_json)
          @imaging_event = create_new_imaging_event
          @media = create_new_media
          @file_set = update_file_set
          add_media_to_imaging_event
          add_original_file
          characterize_file
          create_thumbnail
          add_to_collection_and_save
        end
        @specimen.update_index
        @collection.update_index
      end

      def create_new_imaging_event
        imaging_event = ImagingEvent.create(aperture_value: @slide.aperture_value,
                                            creator: @slide.creator,
                                            date_created: @slide.date_created,
                                            depositor: @manager.user_key,
                                            device_id: [@device.id],
                                            focal_length: @slide.focal_length,
                                            ie_modality: ["SequentialSectionScan"],
                                            optical_magnification: @slide.magnification,
                                            physical_object_id: [@specimen.id],
                                            slide_type: ['Histological'],
                                            software: @slide.scanning_software,
                                            description: @slide.imaging_description,
                                            title: ['new imaging event'])

        Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(ImagingEvent.new, ::Ability.new(@admin), imaging_event.attributes))
        imaging_event.reload
      end

      def create_new_media
        media = Media.create(date_created: @slide.date_created,
                             date_uploaded: Date.today,
                             depositor: @manager.user_key,
                             description: @slide.description,
                             fileset_accessibility: @slide.fileset_accessibility,
                             identifier: @slide.identifier,
                             remote_origin_url: @slide.remote_origin_url,
                             remote_manifest_url: @slide.remote_manifest_url,
                             license: @slide.license,
                             media_type: @slide.media_type,
                             orientation: @slide.orientation,
                             part: @slide.short_description,
                             preview_mode: @slide.preview_mode,
                             publisher: @slide.publisher,
                             rights_holder: @slide.rights_holder,
                             related_url: @slide.related_url,
                             slice_thickness: @slide.slice_thickness,
                             title: @slide.title,
                             unit: @slide.unit,
                             visibility: @slide.visibility,
                             x_spacing: @slide.x_spacing,
                             y_spacing: @slide.y_spacing,
                             z_spacing: @slide.z_spacing)

        Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(Media.new, ::Ability.new(@admin), media.attributes))
        media.reload
      end

      def update_file_set
        fs = @media.file_sets.first
        fs.update(title: [@slide.file_name], label: @slide.file_name, mime_type_of_remote: @slide.mime_type)
        fs.reload
      end

      def add_media_to_imaging_event
        @imaging_event.ordered_members << @media
        @imaging_event.save!
      end

      def add_original_file
        Hydra::Works::AddExternalFileToFileSet.call(@file_set, @file_set.import_url, :original_file, update_existing: true, versioning: false)
      end

      def characterize_file
        file = @file_set.original_file
        @slide.file_characterization_methods.each do |method|
          file.send(method+'=', @slide.send(method))
        end
        file.mime_type = "message/external-body; access-type=URL; URL=\"#{@file_set.import_url}\""
        file.save!
      end

      def add_to_collection_and_save
        @media.member_of_collections += [@collection]
        Hyrax::PermissionTemplateApplicator.apply(@collection.permission_template).to(model: @media)
        @media.save!
        InheritPermissionsJob.perform_later(@media)
      end

      def find_or_create_specimen
        specimen_doc = Morphosource::SolrService.new.get_docs("occurrence_id_tesim:#{occurrence_id} AND has_model_ssim:BiologicalSpecimen")&.first
        return BiologicalSpecimen.find(specimen_doc["id"]) if specimen_doc.present?

        specimen = BiologicalSpecimen.new(title: ['new specimen'],
                                          depositor: @admin.user_key,
                                          date_uploaded: Date.today,
                                          visibility: 'open',
                                          organization_id: [@organization.id],
                                          taxonomy_id: [taxonomy.id])

        params = Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(occurrence_id)
        params.first.each do |key,value|
          specimen.send(key + '=', [value].flatten)
        end

        specimen.save

        Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(BiologicalSpecimen.new, ::Ability.new(@admin), specimen.attributes))
        specimen.reload
      end

      def taxonomy
        taxonomy_doc = Morphosource::SolrService.new.get_docs("has_model_ssim:Taxonomy AND gbif_key_tesim:#{gbif_key}")&.first
        return Taxonomy.find(taxonomy_doc["id"]) if taxonomy_doc.present?

        taxonomy = Taxonomy.new(title: ['new taxonomy'], visibility: 'open', depositor: @admin.user_key, source: ["Imported by Morphosource::Import::SlideSeriesService"])
        params = Morphosource::GbifSearchService.taxonomy_params_from_gbif(gbif_key, correct_synonym=false)
        params.each do |key,value|
          taxonomy.send(key + '=', [value].flatten)
        end

        taxonomy.save

        Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(Taxonomy.new, ::Ability.new(@admin), taxonomy.attributes))
        taxonomy.reload
      end

      private

        def create_series_collection
          collection_type = Hyrax::CollectionType.where(title: "Sequential Section List").first
          collection = SequentialSectionList.create(title: collection_title,
                                                    collection_type_gid: collection_type.gid, depositor: @manager.ms_id,
                                                    visibility: @list_visibility,
                                                    related_url: collection_related_url, description: collection_description)
          collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
          collection.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
          collection.reload
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
