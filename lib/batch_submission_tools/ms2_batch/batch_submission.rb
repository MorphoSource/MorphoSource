module BatchSubmissionTools
  module Ms2Batch
    module BatchSubmission
      include Morphosource::MessageHelper
      include Morphosource::ResqueJobsHelper

      # methods relating to BackgroundJob centralized data tracking

      def background_job
        # Reload to make sure background_job.created_objects gets refreshed during submission process
        BackgroundJob.find(@background_job_id).reload
      end

      def background_job_manifest
        @background_job_manifest ||= background_job.data
      end

      def update_background_job_manifest(path_arr, value)
        @background_job_manifest = background_job.update_data_at_path(Array(path_arr), value)
      end

      # util methods

      def dup_job_found(job_class, background_job_id, ignore_job_id = nil)
        active_jobs(job_class).each do |j|
          # Skip the job if its ID is the one we're supposed to ignore.
          next if ignore_job_id.present? && j["job_id"] == ignore_job_id

          return j["job_id"] if j["arguments"][0] == background_job_id
        end
        return nil
      end

      def pad(id)
        return id unless id.present?
        normalized_id = id.to_s.gsub(/[\r\n]+/, '').strip
        return normalized_id unless normalized_id.present?

        if normalized_id.length < 9
          ("0" * (9 - normalized_id.length)) + normalized_id
        else
          normalized_id
        end
      end

      def empty_row?(row)
        row.each do |cell|
          val = cell[1]
          return false if value_present?(val)
        end
        true
      end

      # Recursively check whether a value contains any non-blank content.
      def value_present?(val)
        case val
        when Hash
          val.values.any? { |v| value_present?(v) }
        when Array
          val.any? { |v| value_present?(v) }
        else
          val.present? && val.to_s.squish.length > 0
        end
      end

      def parse_xlsx_split_sections(input_path)
        parse_input_rows(::Morphosource::Ms2Batch::XLSXParser.new(input_path, false, false))
      end

      # Parse provided row data (e.g., from XLSXParser.each) into manifest sections.
      # Returns the parsed rows and the count of skipped blank rows.
      def parse_input_rows(input_rows)
        parsed_rows = []
        skipped_row_count = 0

        input_rows.each do |row|
          next if row.nil?

          if empty_row?(row)
            skipped_row_count += 1
          else
            parsed_rows << split_sections(row)
          end
        end

        return parsed_rows, skipped_row_count
      end

      def split_sections(row)
        row_data = {}
        # break up each row into sections
        row.each do |field_terms, val|
          field_terms_ary = field_terms.to_s.split('.', 3)
          model = field_terms_ary.first.to_sym
          field = field_terms_ary.last.to_sym
          row_data[model] ||= {}

          if val.is_a?(Hash) && field_terms_ary.length == 1
            # Handle already-sectioned hashes (e.g., deserialized manifest data)
            converted_val = val.each_with_object({}) do |(k, v), h|
              h[k.to_sym] = sanitize_submission_value(Array(v).map(&:to_s))
            end
            row_data[model].merge!(converted_val)
          else
            row_data[model][field] = sanitize_submission_value(Array(val).map(&:to_s))
          end
          # Note: Values will be converted (e.g. from float) to strings, to avoid Invalid datatype error in ActiveFedora::Indexing::InvalidIndexDescriptor
        end
        return row_data
      end

      # Normalize incoming batch strings so embedded newlines do not break IDs/URIs.
      def sanitize_submission_value(value)
        case value
        when Hash
          value.each_with_object({}) { |(k, v), h| h[k] = sanitize_submission_value(v) }
        when Array
          value.map { |v| sanitize_submission_value(v) }
        when String
          value.gsub(/[\r\n]+/, ' ').strip
        else
          value
        end
      end

      def notify_user(user, status, main_job_id)
        subject = "Batch submission job has #{status}."
        message = "Submission job #{@main_job_id} has #{status}.  Please check your Batch Submission Dashboard for details, or contact MorphoSource team if you need assistence."
        deliver_message(email_sender, user, message.html_safe, subject)
      end

    end
  end
end
