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

        def self.call(occurrence_id)
          new(occurrence_id).call
        end

        # return SequentialSectionScanList
        def initialize(id, json = nil, collection = nil)
          @occurrence_id = id
          @occurrence_json = json || occurrence_json
          raise StandardError.new "GBIF occurrence JSON is blank." if @occurrence_json.blank?
          @collection = collection || create_series_collection
        end

        def occurrence_json
          @occurrence_json ||= Morphosource::GbifSearchService.occurrence_record_by_id(@occurrence_id)
        end

        def call
          find_or_create_series_works
          import_slide_series
        end

        def find_or_create_series_works
          @taxonomy = taxonomy
          @specimen = find_or_create_specimen
          @device = device
        end

        def import_slide_series
          Hyrax.config.index_related_works = false
          slides.each do |slide_json|
            @slide = slide_class.new(slide_json)
            create_slide_works
            characterize_file
            create_thumbnail
            add_to_collection_and_save
          end
          update_works_index
        end

        def create_slide_works
          @imaging_event = create_new_imaging_event
          @media = create_new_media
          associate_slide_works
        end

        def associate_slide_works
          @file_set = update_file_set
          add_media_to_imaging_event
          add_original_file
        end

        def update_works_index
          @specimen.update_index
          @collection.update_index
        end

        # find_or_create_series_works

        def find_or_create_specimen
          specimen_doc = search_for_specimen
          return BiologicalSpecimen.find(specimen_doc['id']) if specimen_doc.present?

          specimen = BiologicalSpecimen.new(title: ['new specimen'],
                                            depositor: admin.user_key,
                                            date_uploaded: Date.today,
                                            visibility: 'open',
                                            organization_id: [organization.id],
                                            taxonomy_id: [taxonomy.id])

          update_specimen_with_idigbio_params(specimen)
        end

        def taxonomy
          taxonomy_doc = search_for_taxonomy
          return Taxonomy.find(taxonomy_doc['id']) if taxonomy_doc.present?

          taxonomy = Taxonomy.new(title: ['new taxonomy'],
                                  visibility: 'open',
                                  depositor: admin.user_key, source: ['Imported by Morphosource::Import::SlideSeriesService'])

          update_taxonomy_with_gbif_params(taxonomy)
        end

        def device
          @device ||= detect_device
        end

        def collection
          @collection ||= create_series_collection
        end

        def create_series_collection
          collection_type = Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
          collection = SequentialSectionList.create(title: collection_title,
                                                    collection_type_gid: collection_type.gid,
                                                    depositor: manager.ms_id,
                                                    visibility: @list_visibility,
                                                    related_url: collection_related_url,
                                                    description: collection_description)

          create_groups_and_permissions(collection)
        end

        # create slide works

        def create_new_imaging_event
          imaging_event = ImagingEvent.create(aperture_value: @slide.aperture_value,
                                              creator: @slide.creator,
                                              date_created: @slide.date_created,
                                              depositor: manager.user_key,
                                              device_id: [device.id],
                                              focal_length: @slide.focal_length,
                                              ie_modality: ['SequentialSectionScan'],
                                              optical_magnification: @slide.magnification,
                                              physical_object_id: [@specimen.id],
                                              slide_type: ['Histological'],
                                              software: @slide.scanning_software,
                                              description: @slide.imaging_description,
                                              title: ['new imaging event'])

          update_work(imaging_event)
        end

        def create_new_media
          media = Media.create(date_uploaded: Date.today,
                               media_type: ['Image'],
                               # values from providers.yml
                               agreement_uri: agreement_uri,
                               depositor: manager.user_key,
                               download_reviewer: [download_reviewer.user_key],
                               fileset_accessibility: fileset_accessibility,
                               license: license,
                               morphosource_use_agreement_type: morphosource_use_agreement_type,
                               owner: manager.user_key,
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
                               z_spacing: @slide.z_spacing)

          update_work(media)
        end

        # associate slide works

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

        # characterize file

        def characterize_file
          file = @file_set.original_file
          @slide.file_characterization_methods.each do |method|
            file.send("#{method}=", @slide.send(method))
          end
          file.mime_type = "message/external-body; access-type=URL; URL=\"#{@file_set.import_url}\""
          file.save!
          CalculateFileSetCrc32Job.perform_later(@file_set.id)
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

        # add media to collection

        def add_to_collection_and_save
          @media.member_of_collections += [@collection]
          Hyrax::PermissionTemplateApplicator.apply(@collection.permission_template).to(model: @media)
          @media.save!
          InheritPermissionsJob.perform_later(@media)
        end

        private

          def admin
            @admin ||= User.find_by(ms_id: Hyrax.config.batch_user_key)
          end

          def attributes_from_params(params, object)
            params.each do |key, value|
              object.send("#{key}=", [value].flatten)
            end
          end

          def collection_related_url
            [occurrence_uri, specimen_uri]
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
              []
            end
          end

          def create_groups_and_permissions(collection)
            collection.create_collection_groups
            Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
            collection.reindex_extent = ::Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
            collection.reload
          end

          def detect_device
            scanners.detect { |device| device.title == Array(device_name) }
          end

          def device_name
            first_slide.device || default_device
          end

          def first_slide
            slide_class.new(slides.first)
          end

          def gbif_slides
            media = occurrence_json.dig('extensions', 'http://rs.tdwg.org/ac/terms/Multimedia')
            return media unless filter_slides.present?

            media.select { |m| m['http://rs.tdwg.org/ac/terms/variant'] == filter_slides }
          end

          def occurrence_uri
            "https://gbif.org/occurrence/#{@occurrence_id}"
          end

          def organization
            @organization ||= Organization.find(provider['id'])
          end

          def scanners
            organization.devices.select { |device| device.modality.include? 'SequentialSectionScan' }
          end

          def publishing_key
            occurrence_json['publishingOrgKey']
          end

          def provider
            @provider ||= detect_provider(publishing_key)
          end

          def search_for_specimen
            Morphosource::SolrService.new.get_docs("occurrence_id_tesim:#{@occurrence_json['occurrenceID']} AND has_model_ssim:BiologicalSpecimen")&.first
          end

          def search_for_taxonomy
            Morphosource::SolrService.new.get_docs("has_model_ssim:Taxonomy AND gbif_key_tesim:#{@occurrence_json['taxonKey']}")&.first
          end

          def specimen_params_from_occurrence_id
            Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(@occurrence_json['occurrenceID'])
          end

          def specimen_uri
            occurrence_json['references']
          end

          def slide_class
            "Morphosource::Import::SlideSeries::Slides::#{provider['slide_class']}".constantize || Morphosource::Import::SlideSeries::Slides::Slide
          end

          def slides
            @slides ||= gbif_slides
          end

          def update_specimen_with_idigbio_params(specimen)
            params = specimen_params_from_occurrence_id
            attributes_from_params(params.first, specimen)
            specimen.save
            Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(BiologicalSpecimen.new, ::Ability.new(admin), specimen.attributes))
            specimen.reload
          end

          def update_taxonomy_with_gbif_params(taxonomy)
            gbif_key = occurrence_json["taxonKey"]
            params = Morphosource::GbifSearchService.taxonomy_params_from_gbif(gbif_key, correct_synonym = false)
            attributes_from_params(params, taxonomy)
            taxonomy.save
            Hyrax::CurationConcern.actor.create(Hyrax::Actors::Environment.new(Taxonomy.new, ::Ability.new(admin), taxonomy.attributes))
            taxonomy.reload
          end

          def update_work(work)
            Hyrax::CurationConcern.actor.update(Hyrax::Actors::Environment.new(work.class.new, ::Ability.new(admin), work.attributes))
            work.reload
          end
      end
    end
  end
end
