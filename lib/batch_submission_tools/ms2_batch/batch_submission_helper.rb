module BatchSubmissionTools
  module Ms2Batch
    module BatchSubmissionHelper

      include Morphosource::MessageHelper

      def dup_job_found(job_class, manifest_object, ignore_job_id = nil)
        active_jobs(job_class).each do |j|
          unless ignore_job_id.present? && j["job_id"] == ignore_job_id
            if j["arguments"][0]["summary"].except("_aj_symbol_keys") == manifest_object["summary"]
              return j["job_id"]
            end
          end
        end
        return nil
      end

      def active_jobs(job_class)
        (queued_resque_jobs + working_resque_jobs).select { |j| j["job_class"] == job_class }
      end

      def queued_resque_jobs
        @queued_resque_jobs ||= begin
          Resque.data_store.queue_names
            .map { |n| Resque.data_store.everything_in_queue(n) }
            .flatten
            .map { |j| Resque.decode(j)["args"][0] || {} }  
        end
      end

      def failed_resque_jobs
        @failed_resque_jobs ||= begin
          Resque::Failure.all(0, 999999)
            .map { |j| (j["payload"]["args"][0] || {}).merge(
              "exception" => j["exception"], 
              "error" => j["error"], 
              "failed_at" => j["failed_at"]
            )}  
        end
      end

      def working_resque_jobs
        @working_resque_jobs ||= begin
          Resque.workers
            .map { |w| w.job }
            .select { |j| j.present? }
            .map { |j| (j["payload"]["args"][0] || {}).merge(
              "run_at" => j["run_at"] 
            )}
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
          # Note: Values will be converted (e.g. from float) to strings, to avoid Invalid datatype error in Solrizer::InvalidIndexDescriptor
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