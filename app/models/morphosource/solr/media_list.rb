module Morphosource
  module Solr
    module MediaList

      def list_type
        self["list_type_tesim"]&.first
      end

      def media_list?
        self["human_readable_type_tesim"] == ["Media List"]
      end

    end
  end
end