module Morphosource
  module SpecimenSources
    # Finds the best remote record for an occurrence ID, trying sources in priority order.
    class Resolver
      # status is one of :found, :not_found, :org_mismatch, :invalid_occurrence_id; source_errors lists sources whose lookup failed
      Result = Struct.new(:status, :record, :candidates, :source_errors, keyword_init: true) do
        def found?
          status == :found
        end

        def source_errors
          self[:source_errors] || []
        end
      end

      attr_reader :organization, :sources

      # valid if 8 characters minimum AND has both a letter and a number
      def self.valid_occurrence_id?(occurrence_id)
        occurrence_id = occurrence_id.to_s
        occurrence_id.length >= 8 && occurrence_id.count('0-9') > 0 && occurrence_id.count('a-zA-Z') > 0
      end

      # @param organization_id [String, Array<String>] ID of the specimen's organization
      # @param sources [Array<Base>]
      def initialize(organization_id: nil, sources: Morphosource::SpecimenSources.configured)
        @sources = sources
        organization_id = Array(organization_id).first
        @organization = organization_id.present? ? SolrDocument.find(organization_id) : nil
      rescue Blacklight::Exceptions::RecordNotFound
        @organization = nil
      end

      # @param occurrence_id [String, Array<String>]
      # @return [Result]
      def find_by_occurrence_id(occurrence_id)
        occurrence_id = Array(occurrence_id).first.to_s.strip
        unless self.class.valid_occurrence_id?(occurrence_id)
          return Result.new(status: :invalid_occurrence_id, candidates: [])
        end

        mismatched = []
        source_errors = []
        sources.each do |source|
          records = lookup(source, source_errors) { source.find_by_occurrence_id(occurrence_id) } || []
          next if records.empty?

          matching = records.select { |record| org_matches?(source, record) }
          if matching.empty?
            Rails.logger.debug "SpecimenSources::Resolver: #{source.label} record(s) for #{occurrence_id} not in organization #{organization&.id} datasets"
            mismatched.concat(records)
            next
          end

          return Result.new(status: :found, record: matching.first, candidates: matching, source_errors: source_errors)
        end

        Result.new(status: mismatched.any? ? :org_mismatch : :not_found, candidates: mismatched, source_errors: source_errors)
      end

      # @param source_key [Symbol, String]
      # @return [Record, nil]
      def find_by_id(source_key, id)
        source = Morphosource::SpecimenSources.for(source_key)
        lookup(source) { source.find_by_id(id) }
      end

      private

        def lookup(source, source_errors = [])
          yield
        rescue StandardError => e
          Rails.logger.error "SpecimenSources::Resolver: #{source.label} lookup failed: #{e.message}"
          source_errors << source.key
          nil
        end

        def org_matches?(source, record)
          org_dataset_ids = Array(organization&.[](source.org_dataset_field))
          return true if org_dataset_ids.empty? || record.dataset_id.blank?
          org_dataset_ids.include?(record.dataset_id)
        end
    end
  end
end
