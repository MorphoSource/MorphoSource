# frozen_string_literal: true

module Morphosource
  module Import
    module Slides
      # Service to import a series of sequential section scans from GBIF using a GBIF occurrence id.
      class SlideSeriesService
        include Morphosource::CustomThumbnails
        include Morphosource::Import::SlideSeries::Providers

        # for key/value pairs in providers yml
        # define method with name = key that returns value
        # ex provider['filter_slides'] can be called as filter_slides
        define_provider_methods

        def self.call(occurrence_key)
          new(occurrence_key).call
        end

        # return SequentialSectionScanList
        def initialize(occurrence_key, collection_id = nil)
          @occurrence_key = occurrence_key
          @occurrence_json = occurrence_json
          raise StandardError.new 'GBIF occurrence JSON is blank.' if @occurrence_json.blank?
          @collection = collection_id.present? ? Collection.find(collection_id) : collection
        end

        def occurrence_json
          @occurrence_json ||= Morphosource::GbifSearchService.occurrence_record_by_id(@occurrence_key)
        end

        def call
          find_or_create_series_works
          import_slide_series
          @collection
        end

        # these are located/created using GBIF occurrence metadata
        def find_or_create_series_works
          @taxonomy = taxonomy
          @specimen = find_or_create_specimen
          @device = device
        end

        def import_slide_series
          Hyrax.config.index_related_works = false
          collection_media_ids = []
          slides.each do |slide_json|
            @slide = slide_class.new(slide_json)
            @imaging_event = create_new_imaging_event
            @media = create_new_media
            collection_media_ids << @media.id
            characterize_file unless @slide.metadata_blank?
            create_thumbnail unless @slide.metadata_blank?
            normalize_media if normalize_permissions
            @collection.add_member_objects(@media)
          end
          @specimen.update_index
          collection_media_ids.each { |id| Media.find(id).update_index }
          @collection.update_index
        end

        # find_or_create_series_works

        def find_or_create_specimen
          specimen_doc = search_for_specimen
          return BiologicalSpecimen.find(specimen_doc['id']) if specimen_doc.present?

          specimen = BiologicalSpecimen.new
          params = specimen_params_from_occurrence_id
          attributes = { title: ['new specimen'],
                         depositor: manager.user_key,
                         date_uploaded: Date.today,
                         visibility: 'open',
                         organization_id: [organization.id],
                         taxonomy_id: [taxonomy.id] }.merge(params)

          Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(specimen, ::Ability.new(manager), attributes))
          specimen
        end

        def taxonomy
          taxonomy_doc = search_for_taxonomy
          return Hyrax.query_service.find_by(id: taxonomy_doc['id']) if taxonomy_doc.present?

          params = taxonomy_params_from_gbif
          attributes = {
            visibility: 'open',
            depositor: manager.user_key,
            source: ['Imported by Morphosource::Import::SlideSeriesService']
          }.merge(params)

          Morphosource::Action::CreateWorkService.new(
            model: TaxonomyResource,
            params: { taxonomy_resource: attributes },
            user: manager
          ).call.value!
        end

        def device
          @device ||= detect_device
        end

        def collection
          @collection ||= create_series_collection
        end

        def create_series_collection
          collection_type = Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
          list = SequentialSectionList.create(title: collection_title,
                                                    collection_type_gid: collection_type.to_global_id,
                                                    depositor: manager.ms_id,
                                                    visibility: list_visibility,
                                                    related_url: collection_related_url,
                                                    description: collection_description)
          Morphosource::Collections::PermissionsCreateService.create_default(collection: list)
          list.reload
        end

        # create slide works

        def create_new_imaging_event
          imaging_event = ImagingEvent.new
          attributes = { aperture_value: @slide.aperture_value,
                         creator: @slide.creator,
                         date_created: @slide.date_created,
                         depositor: manager.user_key,
                         device_id: [device.id.to_s],
                         focal_length: @slide.focal_length,
                         ie_modality: ['SequentialSectionScan'],
                         optical_magnification: @slide.magnification,
                         physical_object_id: [@specimen.id.to_s],
                         slide_type: ['Histological'],
                         software: @slide.scanning_software,
                         description: @slide.imaging_description,
                         title: ['new imaging event'] }

          Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(imaging_event, ::Ability.new(manager), attributes))
          imaging_event
        end

        # These are created using a combination of GBIF occurrence metadata, GBIF occurrence individual media metadata, IIIF metadata (including exif), and values from the provider profile.
        # Except for the provider profile values, the rest are aggregated by the Slide class.
        def create_new_media
          media = Media.new
          attributes = { date_uploaded: Date.today,
                         media_type: ['Image'],
                         # values from providers.yml
                         agreement_uri: agreement_uri,
                         depositor: manager.user_key,
                         record_download_reviewer_users: [download_reviewer.ms_id],
                         fileset_accessibility: fileset_accessibility,
                         license: license,
                         morphosource_use_agreement_type: morphosource_use_agreement_type,
                         owner: manager.ms_id,
                         permits_3d_use: permits_3d_use,
                         permits_commercial_use: permits_commercial_use,
                         preview_mode: preview_mode,
                         publisher: publisher,
                         required_archival_of_published_derivatives: required_archival_of_published_derivatives,
                         rights_holder: rights_holder,
                         rights_statement: rights_statement,
                         visibility: visibility,
                         # values from slide metadata
                         date_created: @slide.date_created,
                         description: @slide.description,
                         identifier: @slide.identifier,
                         remote_origin_url: @slide.remote_origin_url,
                         remote_manifest_url: @slide.remote_manifest_url,
                         orientation: @slide.orientation,
                         part: @slide.short_description,
                         related_url: @slide.related_url,
                         slice_thickness: @slide.slice_thickness,
                         title: @slide.title,
                         unit: @slide.unit,
                         x_spacing: @slide.x_spacing,
                         y_spacing: @slide.y_spacing,
                         z_spacing: @slide.z_spacing }

          # add media to imaging event
          attributes.merge!(work_parents_attributes: { '0' => { 'id' => @imaging_event.id, '_destroy' => 'false' } } )

          if @slide.metadata_blank?
            add_note_to_attributes(attributes)
          else
            # provide file name
            attributes.merge!('remote_manifest_info' => { 'file_name' => @slide.file_name.first, 'mime_type_of_remote' => @slide.mime_type } )
          end

          Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(media, ::Ability.new(manager), attributes))
          media
        end

        def add_note_to_attributes(attributes)
          attributes[:short_description] = ["File not available at time of import."]
        end

        # characterize file

        def characterize_file
          file_set = @media.file_sets.first
          file = file_set.original_file
          @slide.file_characterization_methods.each do |method|
            file.send("#{method}=", @slide.send(method))
          end
          file.mime_type = "message/external-body; access-type=URL; URL=\"#{file_set.import_url}\""
          file.save!
          CalculateFileSetCrc32Job.perform_later(file_set.id)
        end

        # create slide thumbnail

        # override Morphosource::CustomThumbnails create_thumbnail
        def create_thumbnail
          copy_remote_file
          create_derivative
          update_thumbnail_id
        end

        def custom_thumbnail
          OpenStruct.new(path: @tempfile.path, tempfile: @tempfile)
        end

        def copy_remote_file
          name = "#{@media.identifier.first} _thumbnail"
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

        # override Morphosource::CustomThumbnails update_thumbnail_id to save the thumbnail_id here.
        # Morphosource::CustomThumbnails reloads and saves the media record with the correct thumbnail_id; when @media is saved afterwards it overwrites media with the un-updated value.
        def update_thumbnail_id
          media.thumbnail_id = media.id
          media.save
        end

        private

          def admin
            @admin ||= User.find_by(ms_id: Hyrax.config.batch_user_key)
          end

          def collection_related_url
            [occurrence_uri, specimen_uri].compact
          end

          def collection_description
            ["Slide collection imported on #{Date.today} based on metadata harvested from GBIF: #{occurrence_uri}."]
          end

          def collection_title
            if occurrence_json['scientificName'].present? && occurrence_json['identifier'].present?
              Array([occurrence_json['identifier'], occurrence_json['scientificName']].join(' '))
            elsif occurrence_json['identifier'].present? && @specimen.present?
              Array([occurrence_json['identifier'], @specimen.title.first, @specimen.taxonomies.first.title.first].join(' '))
            else
              # Collection must have a title to be valid.
              ['Sequential Section Slide Series']
            end
          end

          def detect_device
            scanners.detect { |device| device.title == Array(device_name) }
          end

          def device_name
            first_slide.device || default_device
          end

          def first_slide
            @first_slide ||= slide_class.new(slides.first)
          end

          def gbif_slides
            media = occurrence_json.dig('extensions', 'http://rs.tdwg.org/ac/terms/Multimedia')
            # filter for iiif uri with full area and max size - variant is sometimes not applied correctly.
            media = media.select { |m| m['http://rs.tdwg.org/ac/terms/accessURI'].include?('full/') }
            return media unless filter_slides.present?

            media.select { |m| m['http://rs.tdwg.org/ac/terms/variant'] == filter_slides }
          end

          # Adds media to organizational team
          # Updates media according to team permissions template
          # This will override settings in the providers profile.
          def normalize_media
            OrganizationNormalizationJob.perform_later(media_id: @media.id, organization_id: @organization.id, user_email: org_manager_email, remove_previous_reviewers: false, update_publication_status: true)
          end

          def occurrence_uri
            "https://gbif.org/occurrence/#{@occurrence_key}"
          end

          def organization
            @organization ||= OrganizationCollection.find_by(id: provider['id'])
          end

          def org_manager_email
            @org_manager_email ||= User.find_by(ms_id: @organization.data_manager.first).email
          end

          def scanners
            organization.devices.select { |device| device.modality.include? 'SequentialSectionScan' }
          end

          def publishing_key
            occurrence_json['publishingOrgKey']
          end

          def search_for_specimen
            occurrence_id = @occurrence_json['occurrenceID']
            specimen = Morphosource::SolrService.new.get_docs("has_model_ssim:BiologicalSpecimen AND occurrence_id_ssim:#{occurrence_id&.dump}")&.first # escape special characters when searching
            specimen&.dig('occurrence_id_ssim')&.first == occurrence_id ? specimen : nil
          end

          def search_for_taxonomy
            Morphosource::SolrService.new.get_docs(
              "gbif_key_ssim:#{@occurrence_json['taxonKey']}",
              { fq: ["has_model_ssim:(Taxonomy OR TaxonomyResource)"] }
            )&.first
          end

          def specimen_params_from_occurrence_id
            params = Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(@occurrence_json['occurrenceID']).first
            params.symbolize_keys.transform_values { |v| Array(v).flatten }
          end

          def specimen_uri
            occurrence_json['references']
          end

          def slide_class
            "Morphosource::Import::SlideSeries::Slides::#{provider['slide_class'] || 'Slide'}".constantize
          end

          def slides
            @slides ||= gbif_slides
          end

          def taxonomy_params_from_gbif
            gbif_key = occurrence_json['taxonKey']
            params = Morphosource::GbifSearchService.taxonomy_params_from_gbif(gbif_key, correct_synonym = false)
            params.symbolize_keys.transform_values { |v| Array(v).flatten }
          end

      end
    end
  end
end
