module Morphosource
  class PhysicalObjectIndexer < Morphosource::WorkIndexer

    def generate_solr_document
      super.tap do |solr_doc|
        # data processing for subsequent fields
        organizations = object.organizations
        organization_titles = organizations.map{ |o| o.title.first }
        media = object.media
        related_media_ids = media.map(&:id)
        public_media = media.select { |m| m.visibility == 'open' }
        public_human_readable_media_types = []
        media_member_of_public_collection_ids = []
        public_media_keyword = []

        public_media.each do |m|
          public_human_readable_media_types << m.human_readable_media_type.first
          m.member_of_public_collection_ids.each do |id|
            media_member_of_public_collection_ids << id
          end
          m.keyword.each do |k|
            public_media_keyword << k
          end
        end

        public_human_readable_media_types = public_human_readable_media_types.compact.uniq
        media_member_of_public_collection_ids = media_member_of_public_collection_ids.compact.uniq
        public_media_keyword = public_media_keyword.compact.uniq

        # organization facet
        solr_doc['organization_tesim'] = organization_titles
        solr_doc['organization_sim'] = organization_titles
        solr_doc['organization_id_ssim'] = object.organization_id
        # media types facet
        solr_doc['public_media_type_tesim'] = public_human_readable_media_types
        solr_doc['public_media_type_ssim'] = public_human_readable_media_types
        # media collections
        solr_doc['media_member_of_public_collection_ids_ssim'] = media_member_of_public_collection_ids
        # media tags
        solr_doc['public_media_keyword_tesim'] = public_media_keyword
        solr_doc['public_media_keyword_ssim'] = public_media_keyword
        # related media ids
        solr_doc['related_media_ids_ssim'] = related_media_ids
      end
    end
  end
end
