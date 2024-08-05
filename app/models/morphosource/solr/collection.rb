module Morphosource
  module Solr
    module Collection

      def linked_organization
        self["linked_organization_tesim"]
      end

      def media
        Morphosource::SolrService.new.get_docs("member_of_collection_ids_ssim:#{id} AND has_model_ssim:Media")
      end

      def team?
        self["human_readable_type_tesim"] == ["Team"]
      end

      def project?
        self["human_readable_type_tesim"] == ["Project"]
      end

      def media_inherit_permissions?
        team? || project?
      end
    end
  end
end
