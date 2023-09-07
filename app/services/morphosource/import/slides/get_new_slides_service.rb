# frozen_string_literal: true

module Morphosource
  module Import
    module Slides
      # Check GBIF to see if there are any new occurrence records for MCZ sequential section slides
      # Queue ImportSlideSeriesJobs for any new records
      class GetNewSlidesService
        REQUEST_URL = 'https://api.gbif.org/v1/occurrence/search'
        DATASET_KEY = '4bfac3ea-8763-4f4b-a71a-76a6f5f243d3'

        def self.call
          new.call
        end

        def call
          new_occurrence_keys.each do |key|
            Morphosource::ImportSlideSeriesJob.perform_later(key)
          end
          Rails.logger.debug "#{new_occurrence_keys.count} job(s) queued to import records for GBIF occurrence keys: #{new_occurrence_keys}"
          new_occurrence_keys
        end

        def new_occurrence_keys
          @new_occurrence_keys ||= new_occurrence_ids.each_with_object([]) { |id, gbif_keys| gbif_keys << mcz_slides[id] }
        end

        def new_occurrence_ids
          @new_occurrence_ids ||= mcz_slides.keys - list_occurrence_ids
        end

        # Returns an array of occurrence ids associated with Sequential Section Lists in MorphoSource
        # Ex: ["MCZ:SC:3793", "MCZ:SC:3793", "MCZ:SC:3899", "MCZ:SC:3899"]
        def list_occurrence_ids
          lists = Morphosource::SolrService.new.get_docs('has_model_ssim:SequentialSectionList').map { |d| SolrDocument.find(d['id']) }
          specimens = lists.map(&:list_specimen).compact
          specimens.map(&:occurrence_id).flatten
        end

        # returns a hash of occurrence ids and corresponding gbif occurrence record keys:
        # Ex: { 'MCZ:SC:3762' => '4003231427' }
        def mcz_slides
          @mcz_slides ||= gbif_search_results.each_with_object({}) do |result, hash|
            hash[result['occurrenceID']] = result['key']
          end
        end

        # Searches for keyword 'Sequential'
        # Filters results for records with images beloging to MCZ
        # Returns an array of occurrence records
        def gbif_search_results
          Morphosource::Gbif.search_gbif(REQUEST_URL, search_params)[:data]
        end

        def search_params
          { q: 'Sequential', dataset_key: DATASET_KEY, media_type: 'StillImage', limit: 1000 }
        end
      end
    end
  end
end
