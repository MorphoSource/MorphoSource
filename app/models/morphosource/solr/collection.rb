module Morphosource
  module Solr
    module Collection

      def linked_organization
        self["linked_organization_tesim"]
      end

      def team?
        self["human_readable_type_tesim"] == ["Team"]
      end

      def project?
        self["human_readable_type_tesim"] == ["Project"]
      end
    end
  end
end
