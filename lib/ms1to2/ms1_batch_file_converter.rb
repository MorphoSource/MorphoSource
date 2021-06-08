module Ms1to2
  class Ms1BatchFileConverter
    include Ms1to2::Factories::ImagingEventFactoryBehavior
    include Ms1to2::Factories::MediaFactoryBehavior

    attr_accessor :input_path, :response, :input_data, :normalized_data, :finalized_data

    def self.call(input_path)
      new(input_path).call
    end

    def initialize(input_path)
      @input_path = input_path
      @response = {
        status: 'not yet started',
        steps: {},
        data: {}
      }
    end

    def call
      parse
      normalize # parse ms1 special fields into optimal format
      to_csv(normalized_data, '/vagrant/downloads/out.csv')
      finalize # get ms2 attributes using Ms1to2::Models::BaseObject
      to_csv(finalized_data, '/vagrant/downloads/final.csv')

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
      new_row[:biological_specimen] = Ms1to2::Models::BiologicalSpecimen.new(
        nil, row['ms_specimens'].transform_keys(&:to_sym)
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


      return new_row
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
          'm' => 'M',
          'male' => 'M',
          'f' => 'F',
          'female' => 'F'
        },
      }
    end

    def media_special_fields
      {
        'published' => published_filter,
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
          '1' => '1',
          'raw file of group' => '1',
          '2' => '2',
          'derivative file' => '2'
        },
        'published' => published_filter
      }
    end

    def published_filter
      {
        '0' => '0',
        'not published / not available in public search' => '0',
        '1' => '1',
        'published / available in public search and for download' => '1',
        '2' => '2',
        'published / available in public search / users must request download permission' => '2'
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

    def to_csv(data, csv_path)
      headers = []
      data.first.each do |table_name, table_attrs|
        headers += table_attrs.keys.map { |k| [table_name, k].join('.') }
      end

      CSV.open(csv_path, 'w') do |csv|
        csv << headers
        data.each do |row|
          attr_values = []
          row.values.each do |table_attrs|
            attr_values += table_attrs.values.map { |v| Array(v).first }
          end
          csv << attr_values
        end
      end
    end
  end
end