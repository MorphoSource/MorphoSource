require 'roo'

module Morphosource
    module Ms2Batch
      class XLSXParser
        include Enumerable

        attr_reader :file_name, :skip_blanks, :split_values

        def initialize(file_name, skip_blanks = true, split_values = true)
          @file_name = file_name
          @skip_blanks = skip_blanks
          @split_values = split_values
        end

        def headers
          # todo: might consider extracting from the xlsx
          @headers ||= [
            "media.media_file",
            "media.preview_file",
            "media.publication_status",
            "media.media_type",
            "media.parent_file",
            "media.parent_ms_id",
            "biological_specimen.ms_id",
            "biological_specimen.idigbio_uuid",
            "biological_specimen.occurrence_id",
            "biological_specimen.institution_code",
            "biological_specimen.collection_code",
            "biological_specimen.catalog_number",
            "media.part",
            "media.short_description",
            "media.side",
            "media.description",
            "media.creator",
            "media.orientation",
            "media.identifier",
            "media.keyword",
            "media.date_created",
            "media.related_url",
            "media.x_spacing",
            "media.y_spacing",
            "media.z_spacing",
            "media.slice_thickness",
            "media.series_type",
            "media.unit",
            "media.map_type",
            "biological_specimen.identifier",
            "biological_specimen.related_url",
            "biological_specimen.date_created",
            "biological_specimen.creator",
            "biological_specimen.description",
            "biological_specimen.latitude",
            "biological_specimen.longitude",
            "biological_specimen.numeric_time",
            "biological_specimen.original_location",
            "biological_specimen.periodic_time",
            "biological_specimen.is_type_specimen",
            "biological_specimen.sex",
            "biological_specimen.vouchered",
            "taxonomy.taxonomy_genus",
            "taxonomy.taxonomy_species",
            "taxonomy.taxonomy_subspecies",
            "imaging_event.description",
            "imaging_event.creator",
            "imaging_event.software",
            "imaging_event.date_created",
            "imaging_event.ct.exposure_time",
            "imaging_event.ct.flux_normalization",
            "imaging_event.ct.geometric_calibration",
            "imaging_event.ct.shading_correction",
            "imaging_event.ct.filter_material",
            "imaging_event.ct.filter_thickness",
            "imaging_event.ct.frame_averaging",
            "imaging_event.ct.projections",
            "imaging_event.ct.voltage",
            "imaging_event.ct.power",
            "imaging_event.ct.amperage",
            "imaging_event.ct.surrounding_material",
            "imaging_event.ct.xray_tube_type",
            "imaging_event.ct.target_type",
            "imaging_event.ct.detector_type",
            "imaging_event.ct.detector_pixels_x",
            "imaging_event.ct.detector_pixel_size_x",
            "imaging_event.ct.detector_pixels_y",
            "imaging_event.ct.detector_pixel_size_y",
            "imaging_event.ct.detector_configuration",
            "imaging_event.ct.source_object_distance",
            "imaging_event.ct.source_detector_distance",
            "imaging_event.ct.target_material",
            "imaging_event.ct.rotation_number",
            "imaging_event.ct.phase_contrast",
            "imaging_event.ct.optical_magnification",
            "imaging_event.ct.acquisition_type",
            "imaging_event.photogrammetry.focal_length_type",
            "imaging_event.photogrammetry.background_removal",
            "imaging_event.photography.lens_make",
            "imaging_event.photography.lens_model",
            "imaging_event.photography.light_source",
            "processing_event.creator",
            "processing_event.date_created",
            "processing_event.software",
            "processing_event.description"
          ]
        end

        # @yieldparam attributes [Hash] the attributes from one row of the file
        def each(&_block)

          xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
            data_row = row.drop(2) 
    #      as_csv_table.each do |row|

            yield attributes(headers, data_row)
          end
        end

        def each_with_index(&_block)
          row_index = 8
          xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row| 
            data_row = row #.drop(2) 
    #          data_row.each_with_index do |cell, cell_index|

    #      data_row.each_with_index do |row, index|
            yield attributes(headers, data_row), row_index
            row_index = row_index + 1
          end
        end

        #def parent_arks
        #  as_csv_table['parent_ark'].compact.uniq
        #end

        private

        def attributes(headers, row)
          {}.tap do |processed|
            headers.each_with_index do |header, index|
    #byebug
              extract_field(header, row[index]&.value, processed)
            end
          end
        end

        def extract_field(header, val, processed)
    #      return if skip_blanks && !val.present?
          val = '' if !val.present?
          extract_multi_value_field(header, val, processed)
        end

        def extract_multi_value_field(header, val, processed, key = nil)
          key ||= header.to_sym
          processed[key] ||= []
          if split_values
            processed[key] += val.split(";").map(&:strip)
          else
            processed[key] += val.present? ? Array(val) : []
          end
        end

        def xlsx
          #@csv_table ||= CSV.read(file_name, headers: true, :encoding => 'UTF-8')

          @xlsx ||= Roo::Excelx.new(file_name)
        end

      end
    end
end