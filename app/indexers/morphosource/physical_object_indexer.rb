module Morphosource
  class PhysicalObjectIndexer < Morphosource::WorkIndexer

    def generate_solr_document
      super.tap do |solr_doc|
        # data processing for subsequent fields
        organizations = object.organizations
        organization_titles = organizations.map{ |o| o.title.first }
        # media values
        related_media_ids = media.map { |m| m["id"] }
        # public media values
        public_human_readable_media_types = solr_values(public_media, "human_readable_media_type_ssim")
        public_media_keyword = solr_values(public_media, "keyword_tesim")

        # organization facet
        solr_doc['organization_tesim'] = organization_titles
        solr_doc['organization_ssim'] = organization_titles
        solr_doc['organization_id_ssim'] = object.organization_id

        # media types facet
        solr_doc['public_media_type_tesim'] = public_human_readable_media_types
        solr_doc['public_media_type_ssim'] = public_human_readable_media_types

        # media collections
        solr_doc['media_member_of_public_collection_ids_ssim'] = solr_values(public_media, "member_of_public_collection_ids_ssim")
        solr_doc['media_member_of_team_ids_ssim'] = solr_values(media, "member_of_team_ids_ssim")
        solr_doc['media_member_of_project_ids_ssim'] = solr_values(media, "member_of_project_ids_ssim")
        solr_doc['media_member_of_media_list_ids_ssim'] = solr_values(media, "member_of_media_list_ids_ssim")
        solr_doc['media_member_of_sequential_section_list_ids_ssim'] = solr_values(media, "member_of_sequential_section_list_ids_ssim")
        
        # media tags
        solr_doc['public_media_keyword_tesim'] = public_media_keyword
        solr_doc['public_media_keyword_ssim'] = public_media_keyword
        
        # related media ids
        solr_doc['related_media_ids_ssim'] = related_media_ids
      end
    end

    def solr_values(docs, field)
      docs.map { |d| d[field] }.flatten.compact.uniq
    end

    def media
      @media ||= object.media_solr
    end

    def public_media
      @public_media ||= media.select { |m| m["visibility_ssi"] == 'open' }
    end
  end
end
