module Morphosource
  module Solr
    module SequentialSectionList

      def sequential_section_list?
        self["human_readable_type_tesim"] == ["Sequential Section List"]
      end

      def list_specimen
        return unless sequential_section_list?

        specimen_id = media&.first.to_h['physical_object_id_ssim']&.first
        return unless specimen_id.present?

        SolrDocument.find(specimen_id)
      end

    end
  end
end