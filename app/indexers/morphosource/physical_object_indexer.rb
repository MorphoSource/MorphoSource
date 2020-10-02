module Morphosource
  class PhysicalObjectIndexer < Morphosource::WorkIndexer

    def generate_solr_document
      super.tap do |solr_doc|
        # organization facet
        solr_doc['organization_tesim'] = object.organization_titles
        solr_doc['organization_sim'] = object.organization_titles
        # media types facet
        solr_doc['public_media_type_tesim'] = object.public_human_readable_media_types
        solr_doc['public_media_type_ssim'] = object.public_human_readable_media_types
        # media collections
        solr_doc['media_member_of_public_collection_ids_ssim'] = object.media_member_of_public_collection_ids
        # media tags
        solr_doc['public_media_keyword_tesim'] = object.public_media_keyword
        solr_doc['public_media_keyword_ssim'] = object.public_media_keyword
      end
    end
  end
end
