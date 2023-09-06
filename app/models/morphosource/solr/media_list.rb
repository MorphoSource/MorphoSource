module Morphosource
  module Solr
    module MediaList

      def media_list?
        self["human_readable_type_tesim"] == ["Media List"]
      end

    end
  end
end