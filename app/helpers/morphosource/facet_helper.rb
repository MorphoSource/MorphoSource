module Morphosource
  module FacetHelper

    # *title_by_id methods are used by lib/morphosource/facets/collections to sort/search id-based facets

    # Override https://github.com/samvera/hyrax/blob/7588d785f71522e23ad73daf908151aea1d53165/app/helpers/hyrax/hyrax_helper_behavior.rb#L262
    # Handles 404 error
    def title_by_id(id)
      solr_docs = controller.blacklight_config.repository.find(id).docs
      return nil if solr_docs.empty?

      solr_field = solr_docs.first[ActiveFedora.index_field_mapper.solr_name("title", :stored_searchable)]
      return nil if solr_field.nil?

      solr_field.first
    rescue
      "Record #{id} Not Found"
    end
    alias collection_title_by_id title_by_id

    def device_title_by_id(id)
      doc = SolrDocument.find(id)
      "#{ doc['creator_ssim']&.first || "" } #{ doc['title_tesim']&.first }".strip
    rescue
      id
    end

    def user_name_by_id(id)
      User.find_by(ms_id: id).name
    rescue
      "Unknown User #{id.to_s.upcase}"
    end

    def visibility_label(visibility)
      case visibility
      when 'open'
        "Public"
      when 'restricted'
        "Private"
      end
    end

    # returns the type of records being faceted
    def record_type
      return "Works" unless @response

      doc = @response&.docs&.first
      doc.present? ? doc["has_model_ssim"]&.first&.pluralize&.titleize : "Works"
    end

    def id_helper_method?
      Morphosource::Facets::Collections::ID_HELPER_METHODS.include? @facet&.helper_method
    end

  end
end
