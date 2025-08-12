module BatchSubmissionTools
  module Ms2Batch
    module BatchSubmission
      include Morphosource::MessageHelper
      include Morphosource::ResqueJobsHelper

      # methods relating to BackgroundJob centralized data tracking

      def background_job
        @background_job ||= BackgroundJob.find(@background_job_id)
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
        if id.length < 9
          ("0" * (9 - id.length)) + id
        else
          id
        end
      end

      def empty_row?(row)
        row.each do |cell|
          if cell[1].present?
            if cell[1].first.squish.length > 0
              return false
            end
          end
        end
        return true
      end

      def parse_xlsx_split_sections(input_path)
        input_data = []
        skipped_row_count = 0
        ::Morphosource::Ms2Batch::XLSXParser.new(input_path, false, false).each do |row|
          if empty_row?(row)
            skipped_row_count += 1
          else
            input_data << split_sections(row)
          end
        end
        return input_data, skipped_row_count
      end

      def split_sections(row)
        row_data = {}
        # break up each row into sections
        row.each do |field_terms, val|
          field_terms_ary = field_terms.to_s.split('.', 3)
          model = field_terms_ary.first.to_sym
          field = field_terms_ary.last.to_sym
          row_data[model] = {} if !row_data.key?(model)
          row_data[model][field] = val.map(&:to_s)
          # Note: Values will be converted (e.g. from float) to strings, to avoid Invalid datatype error in ActiveFedora::Indexing::InvalidIndexDescriptor
        end
        return row_data
      end

      def notify_user(user, status, main_job_id)
        subject = "Batch submission job has #{status}."
        message = "Submission job #{@main_job_id} has #{status}.  Please check your Batch Submission Dashboard for details, or contact MorphoSource team if you need assistence."
        deliver_message(email_sender, user, message.html_safe, subject)
      end

    end
  end
end