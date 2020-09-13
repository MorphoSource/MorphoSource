module Morphosource
  class PhysicalObjectIndexer < Morphosource::WorkIndexer

    def generate_solr_document
      super.tap do |solr_doc|
        # organization facet
        solr_doc['organization_tesim'] = object.organization_titles
        solr_doc['organization_sim'] = object.organization_titles
        # media types facet
        solr_doc['media_type_tesim'] = object.human_readable_media_types
        solr_doc['media_type_sim'] = object.human_readable_media_types
        # media collections
        solr_doc['media_collections_tesim'] = object.media_collections
        solr_doc['media_collections_sim'] = object.media_collections
        # media tags
        solr_doc['media_keyword_tesim'] = object.media_keyword
        solr_doc['media_keyword_sim'] = object.media_keyword
      end
    end
  end
end
