module BatchSubmissionTools
  module Ms2Batch
    class BatchFileValidator
      attr_reader :xlsx_file, :user, :organization_id, :modality, :submission_yaml, :xlsx
      attr_reader :device_cache, :organization_cache

      EXPERIMENTAL_FIELDS = [
        "experimental.device_id",
        "experimental.device_modality",
        "experimental.organization_id"
      ]

      ##
      # Validates an excel spreadsheet for a batch submission of multiple media.
      #
      # @param [String, Roo::Excelx] xlsx_file Path to excel file or Roo Excelx object
      # @param [User] user The user submitting the batch
      # @param [String] organization_id ID for the object organization if provided for file
      # @param [String] modality The device modality of the media if provided for file
      def initialize(xlsx_file:, user:, organization_id: nil, modality: nil)
        @xlsx_file = xlsx_file
        @user = user
        @organization_id = organization_id
        @modality = modality
        @submission_yaml = YAML.load_file(Rails.root.join('config','submission.yml'))

        # For experimental multi-org multi-device files
        @device_cache = {}
        @organization_cache = {}
      end

      def xlsx
        @xlsx ||= xlsx_file.is_a?(Roo::Excelx) ? xlsx_file : Roo::Excelx.new(xlsx_file)
      end

      ##
      # Performs validation on excel spreadsheet and returns a JSend-format status hash.
      #
      # @return [Hash] JSend-compatible status hash.
      def validate
        # field names is on row 7
        # field values start from row 8, column 3 (column 1 and 2 can be skipped)
        general_error_msg = ""
        general_warning_msg = ""
        error_rows = {}
        error_messages = {}
        error_cell_numbers = {}
        warn_rows = {}
        warn_messages = {}
        warn_cell_numbers = {}
        row_index = 8
        skipped_row_count = 0

        @mo_idx = 0
        @media_order = { @mo_idx => [] }

        if initial_error_message.present?
          return {
            status: "fail",
            data: {
              general_error_msg: initial_error_message,
              error_rows: error_rows,
              error_messages: error_messages,
              error_cell_numbers: error_cell_numbers,
              warn_rows: warn_rows,
              warn_messages: warn_messages,
              warn_cell_numbers: warn_cell_numbers,
              field_names: field_names,
              row_count: 0
            }
          }
        else
          xlsx.each_row_streaming(offset: 7, pad_cells: true) do |row|
            data_row = row.drop(2)
            if empty_row?(data_row)
              skipped_row_count += 1
            else
              row_cell_errors = []
              error_row_cell_numbers = []
              row_cell_warnings = []
              warn_row_cell_numbers = []
              data_row.each_with_index do |cell, cell_index|
                begin
                  error_msg, warn_msg = error_found(field_names[cell_index], cell, row_index)
                  if error_msg.present?
                    row_cell_errors << error_msg
                    error_rows[row_index] = data_row.map { |c| c.present? ? c.value.to_s : "" }
                    error_row_cell_numbers << cell_index
                  elsif warn_msg.present?
                    row_cell_warnings << warn_msg
                    warn_rows[row_index] = data_row.map { |c| c.present? ? c.value.to_s : "" }
                    warn_row_cell_numbers << cell_index
                  end
                rescue => e
                  Rails.logger.debug "iN BatchSubmissionsController, Exception: #{e.message} -- #{e.inspect} -- #{e.backtrace}"
                  general_error_msg = "ERROR: There are problems parsing some rows in the file.  Please check the details below."
                  row_cell_errors = ["This row is skipped.  If the row appears to be blank, please try deleting or clearing the row. (Exception: #{e.message})"]
                  error_rows[row_index] = data_row.map { |c| c.present? ? c.value : "" }
                  break # skip the rest of the cells
                end
              end # /looping cells
              error_messages[row_index] = row_cell_errors
              error_cell_numbers[row_index] = error_row_cell_numbers
              warn_messages[row_index] = row_cell_warnings
              warn_cell_numbers[row_index] = warn_row_cell_numbers
            end
            row_index = row_index + 1
          end # /lopping rows /xlsx.each_row_streaming
          row_count = row_index - 8 - skipped_row_count
          if error_rows.count > 0
            return {
              status: "fail",
              data: {
                general_error_msg: "There are validation errors.  Please check the details below.",
                error_rows: error_rows,
                error_messages: error_messages,
                error_cell_numbers: error_cell_numbers,
                warn_rows: warn_rows,
                warn_messages: warn_messages,
                warn_cell_numbers: warn_cell_numbers,
                field_names: field_names,
                row_count: row_count
              }
            }
          else
            begin
              return {
                status: "success",
                data: {
                  warn_rows: warn_rows,
                  warn_messages: warn_messages,
                  warn_cell_numbers: warn_cell_numbers,
                  field_names: field_names,
                  row_count: row_count
                }
              }
            rescue Exception => e
              return {
                status: "fail",
                data: {
                  general_error_msg: e.message,
                  error_rows: error_rows,
                  error_messages: error_messages,
                  error_cell_numbers: error_cell_numbers,
                  warn_rows: warn_rows,
                  warn_messages: warn_messages,
                  warn_cell_numbers: warn_cell_numbers,
                  field_names: field_names,
                  row_count: row_count
                }
              }
            end
          end

        end
      end

      def initial_error_message
        # basic validation: check field names, column count
        # standard sheet has 85 columns, experimental multi-device multi-org sheet has 87
        if !(xlsx.last_column == 85 || xlsx.last_column == 88)
          return "The columns are invalid.  Please check the file or download the latest blank submission manifest again."
        elsif xlsx.last_row > 5007
          return "The number of rows has exceeded the maximum."
        end
        # check that each non-experimental field name is present where we expect it to be
        field_names.each_with_index do |fname, idx|
          next if EXPERIMENTAL_FIELDS.include?(fname) # it's fine if these aren't present
          if fname != xlsx.excelx_value(7, idx + 3)
            return "Invalid field name in row 7, column " +  (idx + 3).to_s + " (expecting " + fname + ").  Please check the file or download the blank submission manifest again."
          end
        end
        return ""
      end

      def empty_row?(row)
        row.each do |cell|
          if cell.present? && cell.value.squish.length > 0
            return false
          end
        end
        return true
      end

      def error_found(field_name, cell, current_row)
        val = cell.present? ? cell.value.to_s.strip : ""
        error_msg = ""
        warn_msg = ""
        case field_name
        when "media.media_file"
          if !val.present?
            error_msg = "media.media_file: Please enter a value."
          else
            if val.match(/^https?:\/\//).present?
              # remote file upload
              org_for_row = organization_for_row(current_row)
              if !org_for_row.present?
                error_msg = "media.media_file: No organization information provided, can not evaluate remote file path."
              elsif !user.can_submit_remote_file?(val, org_for_row.id)
                error_msg = "media.media_file: The remote file path is invalid or not allowed. Please make sure you have remote file submitter permissions, organization member permissions, and that the domain for the remote file is allowed."
              else
                rf = MorphosourceHelper::RemoteFileInfo.new(val)
                error_msg = "media.media_file: " + rf.message if rf.message.present?
                # Check if the file extension evaluated from headers content type is an accepted format
                if rf.file_ext.present? && !valid_file_type?(rf.file_ext, cell_value(current_row, field_column("media.media_type")))
                  accepted_formats = accepted_file_formats(cell_value(current_row, field_column("media.media_type")))
                  warn_msg += "The file format returned by the media.media_file URL is " + (rf.file_ext || "unknown") + " and it does not match an accepted format: " + accepted_formats.join(', ')
                end
              end
            else
              # local file upload
              if !val.match?(/^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)*$/)
                error_msg = "media.media_file: File name #{val} is not valid.  Please use a valid file name (alphanumeric, dashes or underscores, with a valid file extension)."
              elsif !File.exist?(File.join(user_share_full_path, val))
                error_msg = "media.media_file: File #{val} cannot be found. Please check your shared folder."
              elsif File.directory?(user_share_full_path + val)
                error_msg = "media.media_file: #{val} is a directory, not a file. Please use a valid file name."
              elsif !valid_file_type?(File.extname(val), cell_value(current_row, field_column("media.media_type")))
                accepted_formats = accepted_file_formats(cell_value(current_row, field_column("media.media_type")))
                error_msg = "media.media_file: File #{val} has file format #{File.extname(val)}, which is not an accepted format for chosen media type. Please use a file with a valid file format or modify the media type to match your file format. Accepted file formats include: #{accepted_formats.join(', ')}."
              end
              if !error_msg.present?
                duplicate_media_found_row = xlsx.column(field_column("media.media_file")).index(val)
                if duplicate_media_found_row + 1 != current_row
                  error_msg = "media.media_file: File #{val} found in more than one row (see row #{duplicate_media_found_row+1})."
                end
              end
            end
          end
        when "media.preview_file"
          if val.present?
            if !val.match?(/^[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)*$/)
              error_msg = "media.preview_file: File name #{val} is not valid.  Please use a valid file name (alphanumeric, dashes or underscores, with a valid file extension)."
            elsif !File.exist?(user_share_full_path + val)
              error_msg = "media.preview_file: File #{val} cannot be found. Please check your shared folder."
            end
          end
        when "media.media_type"
          if valid_media_types.ignore_case_include? val
            val = valid_media_types.ignore_case_included_value val
            if val.downcase != "other"
              # check if media_type value + modality is a permitted combination

              m = valid_modalities.ignore_case_included_value(modality_for_row(current_row))
              if !m.present?
                error_msg = "media.media_type: No modality provided, can not evaluate media type."
              end

              if submission_yaml['status'][val][m] == 'none'
                error_msg = "media.media_type: The combination of media type #{val} and modality #{m} is not permitted. Please provide a different media type or modality."
              end
            end
          else
            error_msg = "media.media_type: Please enter a valid value: " + valid_media_types.to_s.gsub(/\[|\]/, '')
          end
        when "media.parent_file"
          # IF value is present, another row must contain this value in media.media_file
          if val.present?
            if cell_value(current_row, field_column("media.parent_ms_id")).present?
              error_msg = "A value can be present in media.parent_file or media.parent_ms_id, but not in both."
            elsif cell_value(current_row, field_column("media.raw_or_derived")).downcase == "raw"
              error_msg = "A value cannot be present in media.parent_file if media.raw_or_derived value is set to 'Raw'."
            else
              # look for the val in the media_file column
              parent_media_found_row = xlsx.column(field_column("media.media_file")).index(val)
              if parent_media_found_row.present?

                if parent_media_found_row + 1 == current_row
                  error_msg = "media.parent_file #{val} cannot be media.media_file in the same row."
                else
                  @parent_media_row = parent_media_found_row + 1
                  # start building a list, look for the parent of the parent
                  # until found a duplicate, or no more parent
                  parent_chain = [current_row, @parent_media_row]
                  this_row = @parent_media_row
                  no_parent = false
                  duplicate_found = false
                  until no_parent || duplicate_found do
                    next_parent_file = cell_value(this_row, field_column("media.parent_file"))
                    if next_parent_file.present?
                      next_parent_row = xlsx.column(field_column("media.media_file")).index(next_parent_file) + 1
                      if next_parent_row.present?
                        if parent_chain.include? next_parent_row
                          duplicate_found = true
                          error_msg = "media.parent_file #{val} has invalid parent(s) (found in row #{next_parent_row}).  Please check and make sure each parent_file is pointing to the correct row."
                        else
                          parent_chain << next_parent_row
                          this_row = next_parent_row
                        end
                      else
                        #byebug # should not be here since parent file must exists in another column (check validation rule)
                      end
                    else
                      no_parent = true
                    end
                  end # /until
                end
              else
                error_msg = "media.parent_file #{val} not found in another row."
              end
            end
          end
        when "media.parent_ms_id"
          if cell_value(current_row, field_column("media.parent_file")).present?
            # the error_msg should be set in the media.parent_file block already
            #error_msg = "A value can be present in media.parent_file or media.parent_ms_id, but not in both."
          else
            if val.present?
              if cell_value(current_row, field_column("media.raw_or_derived")).downcase == "raw"
                error_msg = "A value cannot be present in media.parent_ms_id if media.raw_or_derived value is set to 'Raw'."
              else
                ms_parent_media = Media.where(id:pad(val.to_s))&.first
                if ms_parent_media.present?
                  if (bso_ms_id = pad(cell_value(current_row, field_column("biological_specimen.ms_id")))).present?
                    if (ms_parent_media.specimens.present?) && (ms_parent_media.specimens.first.id != bso_ms_id)
                      error_msg = "media.parent_ms_id: parent media's specimen id #{ms_parent_media.specimens.first.id} does not match the biological_specimen.ms_id #{bso_ms_id}"
                    end
                  end
                else
                  error_msg = "media.parent_ms_id: Existing media #{val} not found."
                end
              end
              unless error_msg.present?
                @parent_media_id = val
              end
              ignored_experimental_values = []
              if cell_value(current_row, field_column("experimental.organization_id")).present?
                ignored_experimental_values << "experimental.organization_id"
              end
              if cell_value(current_row, field_column("experimental.device_id")).present?
                ignored_experimental_values << "experimental.device_id"
              end
              if ignored_experimental_values.present?
                warn_msg += "The following fields are ignored since media.parent_ms_id exists: " + ignored_experimental_values.join(', ')
              end
            end
          end
        when "media.keyword"
          unless /^[A-Za-zÀ-ÖØ-öø-ÿ0-9 ,]*$/.match(val)
            error_msg = "media.keyword: Value(s) must be letters, accented letters, numbers, and spaces. Use comma as separator."
          end
        when /^media\.(.*)$/
          # note that specific media.* fields (e.g. media.media_type) should be handled above already
          sub_field_name = $1
          supplied_media_type = cell_value(current_row, field_column("media.media_type"))
          if valid_media_types.ignore_case_include? supplied_media_type # no need to check unless media type is valid
            @media_type = valid_media_types.ignore_case_included_value supplied_media_type
            if val.present? && field_to_reject_for_media_type?(@media_type, sub_field_name)
              error_msg = "#{field_name}: Value should not be present for media type #{@media_type}."
            else
              # value that is not rejected (accepted for the media type) can be validated here
              error_msg = error_by_type(field_name, val)
            end
          end
        when "biological_specimen.ms_id"
          if val.present?
            val = pad(val.to_s)
            if (b = BiologicalSpecimen.where(id:val)&.first).present?
              org_for_row = organization_for_row(current_row)
              if !org_for_row.present?
                error_msg = "biological_specimen.ms_id: No organization information provided, can not evaluate existing biological specimen."
              elsif b.organization_id&.first != org_for_row.id
                error_msg = "biological_specimen.ms_id: Existing biological specimen #{val} is associated with an organization different from the one you have selected."
              end
            else
              error_msg = "biological_specimen.ms_id: Existing biological specimen #{val} not found."
            end
            ignored_values = []
            if cell_value(current_row, field_column("biological_specimen.occurrence_id")).present?
              ignored_values << "biological_specimen.occurrence_id"
            end
            if cell_value(current_row, field_column("biological_specimen.institution_code")).present?
              ignored_values << "biological_specimen.institution_code"
            end
            if cell_value(current_row, field_column("biological_specimen.collection_code")).present?
              ignored_values << "biological_specimen.collection_code"
            end
            if cell_value(current_row, field_column("biological_specimen.catalog_number")).present?
              ignored_values << "biological_specimen.catalog_number"
            end
            if cell_value(current_row, field_column("experimental.organization_id")).present?
              ignored_values << "experimental.organization_id"
            end
            if ignored_values.present?
              warn_msg += "The following fields are ignored since biological_specimen.ms_id exists: " + ignored_values.join(', ')
            end
          else
            if !cell_value(current_row, field_column("biological_specimen.occurrence_id")).present? &&
              !cell_value(current_row, field_column("biological_specimen.institution_code")).present? &&
              !cell_value(current_row, field_column("biological_specimen.collection_code")).present? &&
              !cell_value(current_row, field_column("biological_specimen.catalog_number")).present?

              error_msg = "One of the following must have a value: biological_specimen.ms_id, biological_specimen.occurrence_id, biological_specimen.institution_code, biological_specimen.collection_code, and biological_specimen.catalog_number."
            end
          end
        when "biological_specimen.institution_code"
          # If pre-selected organization has existing institution codes, value must match one of the institution codes from the pre-selected organization
          if val.present? && !cell_value(current_row, field_column("biological_specimen.ms_id")).present?
            org_for_row = organization_for_row(current_row)
            if !org_for_row.present?
              error_msg = "biological_specimen.institution_code: No organization information provided, can not evaluate biological specimen institution code."
            elsif !org_for_row.institution_code.map(&:upcase).include?(val.upcase)
              error_msg = "biological_specimen.institution_code: Does not match the institution code from the organization: #{org_for_row.institution_code.join(', ')}"
            end
          end
        when /^imaging_event\.(.*)$/
          case $1
          when /^(ct|photogrammetry|photography)\.(.*)$/
            # handle modality specific fields
            field_modality = $1
            if val.present?
              m = valid_modalities.ignore_case_included_value(modality_for_row(current_row))
              if !m.present?
                error_msg = "#{field_name}: No modality provided, can not evaluate field."
              end

              if field_modality.downcase == modality_mapped(m).downcase
                error_msg = error_by_type(field_name, val)
              else
                # no need to check the values if they should not be present
                error_msg = "#{field_name}: Value should not be present when modality #{modality} is pre-selected."
              end
            end
          else
            # handle non-modality specific fields
            error_msg = error_by_type(field_name, val)
          end
        when /^(biological_specimen|taxonomy|processing_event)\.(.*)$/
          # note that specific *.* fields should be handled above already
          if val.present?
            error_msg = error_by_type(field_name, val)
          end
        when "experimental.device_id"
          if val.present? && !device_for_row(current_row).present?
            error_msg = "experimental.device_id: Device #{val} not found."
          end
        when "experimental.device_modality"
          if val.present?
            if valid_modalities.ignore_case_include?(val)
              val = valid_modalities.ignore_case_included_value(val)
              if !device_for_row(current_row).present?
                error_msg = "experimental.device_modality: Device #{cell_value(current_row, field_column("experimental.device_id"))} not found, can not evaluate device modality."
              elsif !device_for_row(current_row).modality.map(&:upcase).include?(val.upcase)
                error_msg = "experimental.device_modality: #{val} does not match the modality of the device (from device ID or from device of parent media): #{device_for_row(current_row).modality.join(', ')}"
              end

              media_type_for_row = valid_media_types.ignore_case_included_value(cell_value(current_row, field_column("media.media_type")))
              if !media_type_for_row.present?
                error_msg = "experimental.device_modality: Valid media type not found, can not evaluate device modality."
              elsif submission_yaml['status'][media_type_for_row][val] == 'none'
                error_msg = "experimental.device_modality: The combination of media type #{media_type_for_row} and modality #{val} is not permitted. Please provide a different media type or modality. "
              end
            else
              error_msg = "experimental.device_modality: Please enter a valid value: " + valid_modalities.to_s.gsub(/\[|\]/, '')
            end
          end
        when "experimental.organization_id"
          if val.present? && !organization_for_row(current_row).present?
            error_msg = "experimental.organization_id: Organization #{val} not found."
          end
        end
        return error_msg, warn_msg
      end

      def error_by_type(field_name, val)
        error_msg = ""
        case field_types[field_name]
        when /^controlled(_required)?$/
          if !val.present?
            if $1.present?
              error_msg = "#{field_name}: Please enter a valid value."
            end
          else
            unless valid_values_for(field_name).ignore_case_include? val
              error_msg = "#{field_name}: Please enter a valid value: " + valid_values_for(field_name).to_s.gsub(/\[|\]/, '')
            end
          end
        when "boolean"
          unless valid_boolean.ignore_case_include? val
            error_msg = "#{field_name}: Please enter a valid value: " + valid_boolean.to_s.gsub(/\[|\]/, '')
          end
        when /^controlled(_RequiredByMediaType_.*)?$/
          if $1.present?
            by_media_type = $1.split('_').last
            if by_media_type == @media_type
              if !val.present?
                error_msg = "#{field_name}: Value should be present for media type #{by_media_type}."
              else
                required = true
              end
            else
              required = false
            end
          else
            required = false
          end
          if (!error_msg.present?)
            unless (!val.present?) && (!required)
              # this is called by rules, e.g. controlled_RequiredByMediaType_CTImageSeries
              # and will call e.g. valid_media_unit (based on field_name "media_unit") to check for valid values
              unless valid_values_for(field_name).ignore_case_include? val
                error_msg = "#{field_name}: Please enter a valid value: " + valid_values_for(field_name).to_s.gsub(/\[|\]/, '')
              end
            end
          end
        when /^number(_RequiredByMediaType_.*)?$/
          if $1.present?
            by_media_type = $1.split('_').last
            if by_media_type == @media_type
              if !val.present?
                error_msg = "#{field_name}: Value should be present for media type #{by_media_type}."
              else
                required = true
              end
            else
              required = false
            end
          else
            required = false
          end
          if (!error_msg.present?)
            unless (!val.present?) && (!required)
              unless is_number? val
                error_msg = "#{field_name}: Please enter a valid number."
              end
            end
          end
        when "integer"
          unless is_integer? val
            error_msg = "#{field_name}: Please enter a valid integer."
          end
        when "date"
          unless (is_date? val) || (val == '')
            error_msg = "#{field_name}: Please enter a valid date in YYYY-MM-DD or MM-DD-YYYY format."
          end
        end
        return error_msg
      end

      def is_integer?(str)
        Integer(str) != nil rescue false
      end

      def is_number?(str)
        Float(str) != nil rescue false
      end

      def is_date?(str)
        case str
        when /^(\d{4})[\-\/](\d{1,2})[\-\/](\d{1,2})$/
          Date.valid_date? $1.to_i, $2.to_i, $3.to_i
        when /^(\d{1,2})[\-\/](\d{1,2})[\-\/](\d{4})$/
          Date.valid_date? $3.to_i, $1.to_i, $2.to_i
        else
          false
        end
      end

      def pad(id)
        return id unless id.present?
        if id.length < 9
          ("0" * (9 - id.length)) + id
        else
          id
        end
      end

      def field_names
        @field_names ||= field_types.keys
      end

      def field_types
        @field_types ||= {
          "media.media_file" => "text",
          "media.preview_file" => "text",
          "media.media_type" => "controlled_required",
          "media.raw_or_derived" => "controlled_required",
          "media.parent_file" => "text",
          "media.parent_ms_id" => "text",
          "biological_specimen.ms_id" => "text",
          "biological_specimen.occurrence_id" => "text",
          "biological_specimen.institution_code" => "text",
          "biological_specimen.collection_code" => "text",
          "biological_specimen.catalog_number" => "text",
          "media.part" => "text",
          "media.short_description" => "text",
          "media.side" => "controlled",
          "media.description" => "text",
          "media.creator" => "text",
          "media.orientation" => "text",
          "media.identifier" => "text",
          "media.keyword" => "text",
          "media.date_created" => "date",
          "media.related_url" => "text",
          "media.x_spacing" => "number_RequiredByMediaType_CTImageSeries",
          "media.y_spacing" => "number_RequiredByMediaType_CTImageSeries",
          "media.z_spacing" => "number_RequiredByMediaType_CTImageSeries",
          "media.slice_thickness" => "number",
          "media.series_type" => "controlled",
          "media.unit" => "controlled_RequiredByMediaType_CTImageSeries",
          "media.map_type" => "controlled",
          "biological_specimen.identifier" => "text",
          "biological_specimen.related_url" => "text",
          "biological_specimen.date_created" => "date",
          "biological_specimen.creator" => "text",
          "biological_specimen.description" => "text",
          "biological_specimen.latitude" => "number",
          "biological_specimen.longitude" => "number",
          "biological_specimen.numeric_time" => "text",
          "biological_specimen.original_location" => "text",
          "biological_specimen.periodic_time" => "text",
          "biological_specimen.is_type_specimen" => "boolean",
          "biological_specimen.sex" => "controlled",
          "biological_specimen.vouchered" => "boolean",
          "taxonomy.taxonomy_genus" => "text",
          "taxonomy.taxonomy_species" => "text",
          "taxonomy.taxonomy_subspecies" => "text",
          "imaging_event.description" => "text",
          "imaging_event.creator" => "text",
          "imaging_event.software" => "text",
          "imaging_event.date_created" => "text",
          "imaging_event.ct.exposure_time" => "number",
          "imaging_event.ct.flux_normalization" => "boolean",
          "imaging_event.ct.pixel_spacing_calibration" => "controlled",
          "imaging_event.ct.shading_correction" => "boolean",
          "imaging_event.ct.ie_filter" => "text",
          "imaging_event.ct.frame_averaging" => "text",
          "imaging_event.ct.projections" => "text",
          "imaging_event.ct.voltage" => "text",
          "imaging_event.ct.power" => "text",
          "imaging_event.ct.amperage" => "text",
          "imaging_event.ct.surrounding_material" => "text",
          "imaging_event.ct.xray_tube_type" => "text",
          "imaging_event.ct.target_type" => "controlled",
          "imaging_event.ct.detector_type" => "controlled",
          "imaging_event.ct.detector_pixels_x" => "integer",
          "imaging_event.ct.detector_pixel_size_x" => "number",
          "imaging_event.ct.detector_pixels_y" => "integer",
          "imaging_event.ct.detector_pixel_size_y" => "number",
          "imaging_event.ct.detector_configuration" => "controlled",
          "imaging_event.ct.source_object_distance" => "text",
          "imaging_event.ct.source_detector_distance" => "text",
          "imaging_event.ct.target_material" => "text",
          "imaging_event.ct.rotation_number" => "number",
          "imaging_event.ct.phase_contrast" => "boolean",
          "imaging_event.ct.optical_magnification" => "boolean",
          "imaging_event.ct.acquisition_type" => "controlled",
          "imaging_event.photogrammetry.focal_length_type" => "controlled",
          "imaging_event.photogrammetry.background_removal" => "text",
          "imaging_event.photography.lens_make" => "text",
          "imaging_event.photography.lens_model" => "text",
          "imaging_event.photography.light_source" => "controlled",
          "processing_event.creator" => "text",
          "processing_event.date_created" => "date",
          "processing_event.software" => "text",
          "processing_event.description" => "text",
          "experimental.device_id" => "text",
          "experimental.device_modality" => "controlled",
          "experimental.organization_id" => "text"
        }
      end

      def field_column(field)
        # this returns the actual column number of a field (by adding first 2 columns and "0")
        field_names.index(field) + 3
      end

      def valid_values_for(field)
        method_name = "valid_" + field.gsub('.', '_')
        return send(method_name)
      end

      def valid_media_types
        @valid_media_types ||= Morphosource::MediaTypesService.new.select_all_options.map { |o| o[1] }
      end

      def valid_modalities
        @valid_modalities ||= Morphosource::ModalitiesService.new.select_all_options.map { |o| o[1] }
      end

      def valid_file_type?(file_ext, media_type)
        accepted_file_formats(media_type).include? file_ext
      end

      def accepted_file_formats(media_type)
        return [] unless valid_media_types.ignore_case_include? media_type
        media_type = valid_media_types.ignore_case_included_value media_type
        Morphosource::MEDIA_FORMATS[media_type][:extensions]
      end

      def valid_media_raw_or_derived
        @valid_media_raw_or_derived ||= ["Raw", "Derived"]
      end

      def valid_media_side
        @valid_media_side ||= ["Left", "Midline", "NotApplicable", "Right", "Unknown"]
      end

      def valid_media_series_type
        @valid_media_series_type ||= ['Projections', 'Reconstructed image stack', 'Sinograms']
      end

      def valid_media_unit
        @valid_media_unit ||= ['Um', 'Cm', 'Ft', 'In', 'Km', 'M', 'Mi', 'Mm']
      end

      def valid_media_map_type
        @valid_media_map_type ||= ['Color', 'Normal']
      end

      def valid_biological_specimen_sex
        @valid_biological_specimen_sex ||= ['Female', 'Male', 'Unknowable', 'Undetermined', 'Hermaphrodite', 'Gynandromorph']
      end

      def valid_imaging_event_ct_pixel_spacing_calibration
        @valid_imaging_event_ct_pixel_spacing_calibration ||= ['Geometry', 'Fiducial']
      end

      def valid_imaging_event_ct_target_type
        @valid_imaging_event_ct_target_type ||= ['Reflection', 'Transmission']
      end

      def valid_imaging_event_ct_detector_type
        @valid_imaging_event_ct_detector_type ||= ['Direct (X-Ray photoconductor)', 'Scintillator (Phosphor used)', 'Storage (Storage Phosphor)', 'Film (Scanned film/screen)']
      end

      def valid_imaging_event_ct_detector_configuration
        @valid_imaging_event_ct_detector_configuration ||= ['Area (single or tiled detector)', 'Slot (scanned slot, slit, or spot)']
      end

      def valid_imaging_event_ct_acquisition_type
        @valid_imaging_event_ct_acquisition_type ||= ['ConstantAngle', 'Free', 'Sequenced', 'Spiral', 'Stationary']
      end

      def valid_imaging_event_photogrammetry_focal_length_type
        @valid_imaging_event_photogrammetry_focal_length_type ||= ['Variable', 'Fixed']
      end

      def valid_imaging_event_photography_light_source
        @valid_imaging_event_photography_light_source ||= ['Strobe', 'Static', 'Patterned', 'Cross polarized']
      end

      def valid_boolean
        @valid_boolean ||= ['Yes', 'No', 'Y', 'N', 'true', 'false', '0', '1']
      end

      def field_to_reject_for_media_type?(media_type, field)
        case media_type
        when 'CTImageSeries'
          ['map_type'].include? field
        when 'PhotogrammetryImageSeries'
          ['x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness', 'unit', 'map_type'].include? field
        when 'Mesh'
          ['series_type', 'x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness'].include? field
        else
          ['series_type', 'x_spacing', 'y_spacing', 'z_spacing', 'slice_thickness', 'unit', 'map_type'].include? field
        end
      end

      def modality_mapped(m)
        case m
        when 'MicroNanoXRayComputedTomography'
          'ct'
        when 'MagneticResonanceImaging'
          'MRI'
        when 'PositronEmissionTomography'
          'PET'
        when 'SinglePhotonEmissionComputedTomography'
          'SPECT'
        when 'NeutronComputedTomography'
          'NCT'
        when 'SynchrotronImaging'
          'Synchro'
        when 'NeutrinoImaging'
          'Neutrino'
        when 'Photogrammetry'
          'photogrammetry'
        when 'StructuredLight'
          'StrLight'
        when 'LaserScan'
          'Laser'
        when 'ConfocalImageStacking'
          'Confocal'
        when 'LightSheetFluorescenceMicroscopy'
          'LSFM'
        when 'Infrared'
          'Infrared'
        when 'ReflectanceTransformationImaging'
          'RTI'
        when 'Photography'
          'photography'
        when 'ScanningElectronMicroscopy'
          'SEM'
        when 'BornDigital'
          'BD'
        when 'XRay'
          'XRay'
        when 'LaserAidedProfiling'
          'LAP'
        when 'Video'
          'Video'
        else
          'Etc'
        end
      end

      def cell_value(row_num, col_num)
        val = xlsx.cell(row_num, col_num)
        if val.nil?
          return nil
        else
          return val.to_s.strip
        end
      end

      # if parent media ID is specified for the row, return SolrDocument for parent media, else return nil
      def parent_media_for_row(row_num)
        if (parent_ms_id = cell_value(row_num, field_column("media.parent_ms_id"))).present?
          if (parent_media_solr = SolrDocument.find(pad(parent_ms_id))).present?
            return parent_media_solr
          end 
        end
        return nil
      end

      # if specimen ID is specified for the row, return SolrDocument for the specimen, else return nil
      def specimen_for_row(row_num)
        if (bso_ms_id = pad(cell_value(row_num, field_column("biological_specimen.ms_id")))).present?
          if (specimen_solr = SolrDocument.find(pad(bso_ms_id))).present?
            return specimen_solr
          end
        end
        return nil
      end

      # For experimental multi-device multi-org sheets, get Device for row or return nil if not present
      def device_for_row(row_num)
        # if parent media is present, get device from parent media
        # otherwise, get device from experimental.device_id if present
        if parent_media_for_row(row_num).present?
          device_id = parent_media_for_row(row_num)["media_device_id_ssim"]&.first
        else
          device_id = pad(cell_value(row_num, field_column("experimental.device_id")))
        end

        return nil if !device_id.present?

        if device_cache[device_id].present?
          device_cache[device_id]
        elsif Device.exists?(device_id)
          device_cache[device_id] = Device.find(device_id)
          device_cache[device_id]
        end
      end

      # Return file-level modality or, for experimental multi-device multi-org files, return row-level modality
      def modality_for_row(row_num)
        return modality if modality.present?  # return modality from batch submission form 

        # return device modality if device has only one modality
        # otherwise return cell value from experimental.device_modality
        if device_for_row(row_num).present? && device_for_row(row_num).modality.count == 1
          return device_for_row(row_num).modality.first
        else
          return cell_value(row_num, field_column("experimental.device_modality"))
        end        
      end

      # Return file-level organization or, for experimental multi-device multi-org files, return row-level organization
      def organization_for_row(row_num)
        if organization_id.present? # return organization from batch submission form
          org_id = organization_id
        else
          # if parent media is present, get organization from parent media
          # or if biological specimen is present, get organization from biological specimen
          # otherwise, get organization from experimental.organization_id 
          if parent_media_for_row(row_num).present?
            org_id = parent_media_for_row(row_num)["media_organization_id_ssim"]&.first 
          elsif specimen_for_row(row_num).present?
            org_id = specimen_for_row(row_num)["organization_id_ssim"]&.first
          else
            org_id = pad(cell_value(row_num, field_column("experimental.organization_id")))
          end
        end

        return nil if !org_id.present?

        if organization_cache[org_id].present?
          organization_cache[org_id]
        elsif OrganizationCollection.exists?(org_id)
          organization_cache[org_id] = OrganizationCollection.find(org_id)
          organization_cache[org_id]
        elsif Organization.exists?(org_id)
          organization_cache[org_id] = Organization.find(org_id)
          organization_cache[org_id]
        end
      end

      def user_share_full_path
        @user_share_full_path ||= begin
          user_set_path = user.sftp_share
          if !user_set_path.present?
            "NOT_FOUND"
          elsif Dir.exist?(Hyrax.config.sftp_share_root + user_set_path)
            File.join(Hyrax.config.sftp_share_root, user_set_path, '/')
          elsif Dir.exist?(user_set_path)
            unless user_set_path.match(/^\//)
              # if relative path, change it to absolute
              File.join(Rails.root, user_set_path, '/')
            else
              File.join(user_set_path, '/')
            end
          else
            "NOT_FOUND"
          end
        end
      end
    end
  end
end
