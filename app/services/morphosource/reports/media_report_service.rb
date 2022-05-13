module Morphosource
  module Reports
    # Enhanced media report hashes for CSV and JSON exports, APIs
    class MediaReportService
      attr_reader :documents, :doc_semantic_values
      attr_accessor :results

      def self.from_solr_documents(documents = [])
        new(documents).from_solr_documents
      end

      def initialize(documents = [])
        @documents = documents
      end

      def from_solr_documents
        @results = documents.map(&:to_semantic_values)
        transform_user_keys_to_names
        @results
      end

      private

      def transform_user_keys_to_names
        managers = @results.pluck(:data_manager).uniq
        depositors = @results.pluck(:data_depositor).uniq
        users = (managers | depositors).map { |key| [key, User.find_by_user_key(key).name_and_email] }.to_h

        return unless users.present?
        @results = @results.map do |result|
          result.merge(
            data_manager: users[result[:data_manager]],
            data_depositor: users[result[:data_depositor]]
          )
        end
      end
    end
  end
end