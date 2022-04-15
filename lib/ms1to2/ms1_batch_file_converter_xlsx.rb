require 'axlsx'

module Ms1to2
  class Ms1BatchFileConverterXlsx
    include Ms1to2::Factories::ImagingEventFactoryBehavior
    include Ms1to2::Factories::MediaFactoryBehavior

    attr_accessor :input_path, :output_path, :response, :input_data, :normalized_data, :finalized_data

    def self.call(input_path, output_path)
      new(input_path, output_path).call
    end

    def initialize(input_path, output_path)
      @input_path = input_path
      @output_path = output_path
      @response = {
        status: 'not yet started',
        steps: {},
        data: {}
      }
    end

    def call
      parse
      normalize # parse ms1 special fields into optimal format
      finalize # get ms2 attributes using Ms1to2::Models::BaseObject

      to_xlsx(finalized_data, output_path)

      return response
    end

    def finalize
      # update response
      response[:steps][:final] = { status: 'in progress' }

      @finalized_data = normalized_data.map.with_index { |row, index| finalize_row(row, index) }

      # update response
      response[:steps][:final][:status] = 'success'
      response[:data][:final] = finalized_data
    end

    def finalize_row(row, index)
      new_row = {}

      # process initial whole-row metadata
      new_row[:metadata] = {
        original_index: row['metadata']['original_row'],
        raw_or_derived: row['ms_media_files']['file_type']
      }

      # process ms_taxonomy table to get taxonomy attributes
      new_row[:taxonomy] = Ms1to2::Models::Taxonomy.new(
        nil, row['ms_taxonomy_names'].transform_keys(&:to_sym)
      )
      .ms2_attributes
      .except(:id)

      # process ms_specimens table to get biological_specimen attributes
      bso = row['ms_specimens'].transform_keys(&:to_sym)
      bso.merge!(vouchered_attribute(bso))

      new_row[:biological_specimen] = Ms1to2::Models::BiologicalSpecimen.new(
        nil, bso
      )
      .ms2_attributes
      .except(:id)
      .merge(id: [ derive_specimen_id(row['ms_specimens']['specimen_id']&.first) ] )

      # process ms_media and ms_media_files tables to get
      # imaging event, processing event, and media attributes
      mg = row['ms_media'].transform_keys(&:to_sym)
      mf = row['ms_media_files'].transform_keys(&:to_sym)

      new_row[:imaging_event] = Ms1to2::Models::ImagingEvent.new(
        nil,
        mg,
        { :power => derive_ie_power(mg) }
      )
      .ms2_attributes
      .except(:id)

      new_row[:processing_event] = Ms1to2::Models::ProcessingEvent.new(
        nil,
        mg
      )
      .ms2_attributes
      .except(:id)

      new_row[:media] = Ms1to2::Models::Media.new(
        nil,
        mg,
        derive_special_fields_mf(mf, mg, nil)
          .except(:depositor, :parent_id, :download_reviewer, :modality)
      )
      .ms2_attributes
      .except(:id)
      new_row[:media][:media_file] = mf[:media]

      # add additional ms1-to-ms2 mapped field & value pairs
#      new_row[:media][:raw_or_derived] = row['ms_media_files']['file_type']
#      new_row[:media][:side] = row['ms_media']['side'] # or row['ms_media_files']['side'] ?
#      new_row[:media][:publication_status] = row['ms_media_files']['published']
#      new_row[:biological_specimen][:ms_id] = row['ms_specimens']['specimen_id']
      #new_row[:biological_specimen][:vouchered] = row['ms_specimens']['reference_source']
#byebug
      return new_row
    end

    def vouchered_attribute(bso)
      if bso[:reference_source].present?
        {}
      else
        { reference_source: ['0'] }
      end
    end

    def derive_specimen_id(id)
      return nil unless id.present?
      id.length == 9 ? id : ("0" * (9 - id.length - 1)) + 'S' + id
    end

    def parse
      # update response
      response[:status] = 'in progress'
      response[:steps][:input] = { status: 'in progress' }

      @input_data = []
      Ms1to2::CSVParser.new(input_path, false, false).each_with_index do |row, index|
        input_data.concat hashify(row, index)
      end

      # update response
      response[:steps][:input][:status] = 'success'
      response[:data][:input] = input_data
    end

    def hashify(row, original_index)
      row_data = {}

      # break up each row into sections
      row.each do |field_terms, val|
        model, field = field_terms.to_s.split('.', 2)
        row_data[model] = {} if !row_data.key?(model)

        # special handling for ms_media_files
        if model == 'ms_media_files'
          media_field, media_number = field.to_s.split('.', 2)
          row_data[model][media_number] = {} if !row_data[model].key?(media_number)
          row_data[model][media_number][media_field] = val
        else
          row_data[model][field] = val
        end
      end

      final_hashes = []

      # how many media files are present?
      row_data['ms_media_files'].each do |key, h|
        next unless h.values.any? { |x| x.present? }
        final_hashes << row_data.except('ms_media_files').merge({
          'ms_media_files' => h,
          'metadata' => {
            'original_row' => [ original_index ]
          }
        })
      end
      
      return final_hashes
    end

    def normalize
      # update response
      response[:steps][:normalize] = { status: 'in progress' }

      @normalized_data = input_data.map.with_index { |row, index| normalize_row(row, index) }

      # update response
      response[:steps][:normalize][:status] = 'success' if ( response[:steps][:normalize][:status] != 'failure' && response[:steps][:normalize][:status] != 'warnings' )
      response[:data][:normalize] = normalized_data
    end

    def normalize_row(row, index)
      row.map do |table_name, table_attrs|
        [table_name, normalize_table(table_attrs, get_table_special_fields(table_name), index, table_name)]
      end.to_h
    end

    def normalize_table(attrs, special_fields, idx, table_name)
      attrs.map do |field, val|
        if special_fields.key?(field) && val.present?
          v = val&.first.to_s.downcase
          if special_fields[field].key?(v)
            new_val = [special_fields[field][v]] # filtered value
          else
            # special field value is not in our pre-determined filters, raise a warning but return original value
            response[:steps][:normalize][:status] = 'warnings'
            response[:steps][:normalize][:warnings] = [] if !response[:steps][:normalize].key?(:warnings)
            warning_text = "Row #{idx} table #{table_name} has invalid value #{v} for field #{field}. Valid values are #{special_fields[field].keys.join('; ')}."
            response[:steps][:normalize][:warnings] << warning_text
            warn(warning_text)

            new_val = val
          end
        else
          new_val = val # return original value
        end

        [field, new_val]
      end.to_h
    end

    def get_table_special_fields(table_name)
      tsf = {
        'ms_specimens' => specimen_special_fields,
        'ms_media' => media_special_fields,
        'ms_media_files' => media_file_special_fields
      }

      tsf.key?(table_name) ? tsf[table_name] : {}
    end

    def specimen_special_fields
      {
        'reference_source' => {
          '0'           => '0',
          'vouchered'   => '0',
          '1'           => '1',
          'unvouchered' => '1'
        },
        'type' => {
          '0'           => '0',
          'yes'         => '0',
          '1'           => '1',
          'no'          => '1'
        },
        'sex' => {
          'm' => 'Male',
          'male' => 'Male',
          'f' => 'Female',
          'female' => 'Female'
        },
      }
    end

    def media_special_fields
      {
        'visibility' => published_filter,
        'side' => side_filter,
        'is_copyrighted' => boolean_filter,
        'copyright_permission' => {
          '0' => '0',
          'copyright permission not set' => '0',
          '1' => '1',
          'person loading media owns copyright and grants permission for use of media on morphosource' => '1',
          '2' => '2',
          'permission to use media on morphosource granted by copyright holder' => '2',
          '3' => '3',
          'permission pending' => '3',
          '4' => '4',
          'popyright expired or work otherwise in public domain' => '4',
          '5' => '5',
          'copyright permission not yet requested' => '5'
        },
        'copyright_license' => {
          '0' => '0',
          'media reuse policy not set' => '0',
          '1' => '1',
          'cc0 - relinquish copyright' => '1',
          '2' => '2',
          'attribution cc by - reuse with attribution' => '2',
          '3' => '3',
          'attribution-noncommercial cc by-nc - reuse but noncommercial' => '3',
          '4' => '4',
          'attribution-sharealike cc by-sa - reuse here and applied to future uses' => '4',
          '5' => '5',
          'attribution- cc by-nc-sa - reuse here and applied to future uses but noncommercial' => '5',
          '6' => '6',
          'attribution-noderivs cc by-nd - reuse but no changes' => '6',
          '7' => '7',
          'attribution-noncommercial-noderivs cc by-nc-nd - reuse noncommerical no changes' => '7',
          '8' => '8',
          'media released for onetime use, no reuse without permission' => '8',
          '20' => '20',
          'unknown - will set before project publication' => '20',
        },
        'scanner_calibration_shading_correction' => boolean_filter,
        'scanner_calibration_flux_normalization' => boolean_filter,
        'scanner_calibration_geometric_calibration' => boolean_filter,
      }
    end

    def media_file_special_fields
      {
        'side' => side_filter,
        'use_for_preview' => boolean_filter,
        'file_type' => {
          '1' => 'Raw',
          'raw file of group' => 'Raw',
          'raw' => 'Raw',
          '2' => 'Derived',
          'derivative file' => 'Derived',
          'derivative' => 'Derived'
        },
        'published' => published_filter
      }
    end

    def published_filter
      {
        '0' => 'Private',
        'not published / not available in public search' => 'Private',
        '1' => 'Open',
        'published / available in public search and for download' => 'Open',
        '2' => 'RestrictedDownload',
        'published / available in public search / users must request download permission' => 'RestrictedDownload'
      }
    end

    def side_filter
      {
        'left' => 'LEFT',
        'midline' => 'MIDLINE',
        'na' => 'NA',
        'not applicable' => 'NA',
        'right' => 'RIGHT',
        'unknown' => 'UNKNOWN'
      }
    end

    def boolean_filter
      {
        '1' => '1', 'true' => '1', 'yes' => '1',
        '0' => '0', 'false' => '0', 'no' => '0'
      }
    end

    def converted_value(field, value)
      case field 
      when "media.publication_status"
        case value
        when 'restricted'
          'RestrictedDownload'
        else
          value.capitalize
        end
      else
        value
      end 
    end

    def mapped_value(row, field_name, mapped_field_name)
      value = ""
      if mapped_field_name.present?
        model_attribute_array = mapped_field_name.split('.') 
        model = model_attribute_array.first
        attribute = model_attribute_array.last
        if row[model.to_sym].present?
          value = row[model.to_sym][attribute.to_sym]
          if value.kind_of?(Array)
            value = converted_value(field_name, value.first)
          else
            value = converted_value(field_name, value)
          end
          puts "Found value for " + model + " " + attribute + " = " + value
        else
          value = ""
        end
      else
        value = "" # + field_name
      end
      return value
    end

    def to_xlsx(data, xlsx_path)
      p = Axlsx::Package.new
      wb = p.workbook
      headers = ["Field Name (Machine Readable)", "Field name formatted to be read by software."] + field_mapped.keys
      wb.add_worksheet(name: 'Ms1 Batch File Converted') do |sheet|
        sheet.add_row headers
        data.each do |row|
          attr_values = ["", ""]
          field_mapped.each do |field_name, mapped_field_name|
            value = mapped_value(row, field_name, mapped_field_name)
            attr_values << value
          end

#byebug
          sheet.add_row attr_values
        end

      end
      p.serialize xlsx_path
    end

    def field_mapped
      @field_mapped ||= {
        "media.media_file" => "media.media_file",
        "media.preview_file" => "",
        "media.publication_status" => "media.visibility",
        "media.media_type" => "media.media_type",
        "media.raw_or_derived" => "metadata.raw_or_derived",
        "media.parent_file" => "",
        "media.parent_ms_id" => "",
        "biological_specimen.ms_id" => "biological_specimen.id",
        "biological_specimen.idigbio_uuid" => "",
        "biological_specimen.occurrence_id" => "biological_specimen.occurrence_id",
        "biological_specimen.institution_code" => "biological_specimen.institution_code",
        "biological_specimen.collection_code" => "biological_specimen.collection_code",
        "biological_specimen.catalog_number" => "biological_specimen.catalog_number",
        "media.part" => "media.part",
        "media.short_description" => "media.short_description",
        "media.side" => "media.side",
        "media.description" => "media.description",
        "media.creator" => "",
        "media.orientation" => "",
        "media.identifier" => "",
        "media.keyword" => "",
        "media.date_created" => "",
        "media.related_url" => "",
        "media.x_spacing" => "media.x_spacing",
        "media.y_spacing" => "media.y_spacing",
        "media.z_spacing" => "media.z_spacing",
        "media.slice_thickness" => "",
        "media.series_type" => "",
        "media.unit" => "media.unit",
        "media.map_type" => "",
        "biological_specimen.identifier" => "",
        "biological_specimen.related_url" => "biological_specimen.related_url",
        "biological_specimen.date_created" => "biological_specimen.date_created",
        "biological_specimen.creator" => "biological_specimen.creator",
        "biological_specimen.description" => "biological_specimen.description",
        "biological_specimen.latitude" => "biological_specimen.latitude",
        "biological_specimen.longitude" => "biological_specimen.longitude",
        "biological_specimen.numeric_time" => "biological_specimen.numeric_time",
        "biological_specimen.original_location" => "biological_specimen.original_location",
        "biological_specimen.periodic_time" => "biological_specimen.periodic_time",
        "biological_specimen.is_type_specimen" => "biological_specimen.is_type_specimen",
        "biological_specimen.sex" => "biological_specimen.sex",
        "biological_specimen.vouchered" => "biological_specimen.vouchered",
        "taxonomy.taxonomy_genus" => "taxonomy.taxonomy_genus",
        "taxonomy.taxonomy_species" => "taxonomy.taxonomy_species",
        "taxonomy.taxonomy_subspecies" => "taxonomy.taxonomy_subspecies",
        "imaging_event.description" => "imaging_event.description",
        "imaging_event.creator" => "imaging_event.creator",
        "imaging_event.software" => "",
        "imaging_event.date_created" => "",
        "imaging_event.ct.exposure_time" => "imaging_event.exposure_time",
        "imaging_event.ct.flux_normalization" => "imaging_event.flux_normalization",
        "imaging_event.ct.geometric_calibration" => "imaging_event.geometric_calibration",
        "imaging_event.ct.shading_correction" => "imaging_event.shading_correction",
        "imaging_event.ct.ie_filter" => "imaging_event.ie_filter",
        "imaging_event.ct.frame_averaging" => "imaging_event.frame_averaging",
        "imaging_event.ct.projections" => "imaging_event.projections",
        "imaging_event.ct.voltage" => "imaging_event.voltage",
        "imaging_event.ct.power" => "imaging_event.power",
        "imaging_event.ct.amperage" => "imaging_event.amperage",
        "imaging_event.ct.surrounding_material" => "imaging_event.surrounding_material",
        "imaging_event.ct.xray_tube_type" => "",
        "imaging_event.ct.target_type" => "",
        "imaging_event.ct.detector_type" => "",
        "imaging_event.ct.detector_pixels_x" => "",
        "imaging_event.ct.detector_pixel_size_x" => "",
        "imaging_event.ct.detector_pixels_y" => "",
        "imaging_event.ct.detector_pixel_size_y" => "",
        "imaging_event.ct.detector_configuration" => "",
        "imaging_event.ct.source_object_distance" => "",
        "imaging_event.ct.source_detector_distance" => "",
        "imaging_event.ct.target_material" => "",
        "imaging_event.ct.rotation_number" => "",
        "imaging_event.ct.phase_contrast" => "",
        "imaging_event.ct.optical_magnification" => "",
        "imaging_event.ct.acquisition_type" => "",
        "imaging_event.photogrammetry.focal_length_type" => "",
        "imaging_event.photogrammetry.background_removal" => "",
        "imaging_event.photography.lens_make" => "",
        "imaging_event.photography.lens_model" => "",
        "imaging_event.photography.light_source" => "",
        "processing_event.creator" => "processing_event.creator",
        "processing_event.date_created" => "",
        "processing_event.software" => "",
        "processing_event.description" => ""
      }
    end

  end

end