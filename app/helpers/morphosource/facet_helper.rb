module Morphosource
  module FacetHelper

    # Override https://github.com/samvera/hyrax/blob/7588d785f71522e23ad73daf908151aea1d53165/app/helpers/hyrax/hyrax_helper_behavior.rb#L262
    # Handles 404 error
    def collection_title_by_id(id)
      begin
        solr_docs = controller.repository.find(id).docs
        return nil if solr_docs.empty?
        solr_field = solr_docs.first[Solrizer.solr_name("title", :stored_searchable)]
        return nil if solr_field.nil?
        solr_field.first
      rescue
        "Collection #{id} Not Found"
      end
    end
  end
end
