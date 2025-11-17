# frozen_string_literal: true

# Copied from Hyrax 5.0.5 to fix issue with indexing PcdmCollection.based_near
module Hyrax
  ##
  # Indexes properties common to Hyrax::Resource types
  module LocationIndexer
    def to_solr
      super.tap do |index_document|
        index_document[:based_near_label_tesim] = index_document[:based_near_label_sim] = based_near_label_lookup(resource.based_near) if (resource.respond_to?(:based_near) && resource.based_near.present?)
      end
    end

    private

    def based_near_label_lookup(locations)
      locations.map do |loc|
        location_service.full_label(loc) if loc.present?
      end
    end

    def location_service
      Hyrax.config.location_service
    end
  end
end
