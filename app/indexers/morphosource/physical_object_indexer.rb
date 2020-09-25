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
        solr_doc['media_member_of_collection_ids_tesim'] = object.media_collections_ids
        solr_doc['media_member_of_collection_ids_ssim'] = object.media_collections_ids
        # media tags
        solr_doc['media_keyword_tesim'] = object.media_keyword
        solr_doc['media_keyword_sim'] = object.media_keyword
        # media ids
        solr_doc['media_type_ids_ssim'] = object.media_ids
        solr_doc['media_keyword_ids_ssim'] = object.media_ids
        solr_doc['child_media_ids_ssim'] = object.media_ids
      end
    end
  end
end
