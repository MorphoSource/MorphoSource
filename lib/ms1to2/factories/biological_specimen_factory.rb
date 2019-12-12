module Ms1to2
  module Factories
    class BiologicalSpecimenFactory < ObjectFactory
      self.ms1_table_name = :ms_specimens
      self.ms2_model = :BiologicalSpecimen

      def derive_id(id)
        hyraxify("S"+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id]),
          :parent_id => derive_bs_parents(v),
          :collection_id => derive_collection_id(v[:project_id])
        }
      end

      def derive_bs_parents(v)
        if v[:alt_id].presence
          [hyraxify("I"+v[:institution_id].first), hyraxify("T"+v[:alt_id].first)]
        else
          [hyraxify("I"+v[:institution_id].first)]
        end
      end
    end
  end
end