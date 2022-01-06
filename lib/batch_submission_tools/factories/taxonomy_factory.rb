module Ms1to2
  module Factories
    class TaxonomyFactory < ObjectFactory
      self.ms1_table_name = :ms_taxonomies
      self.ms2_model = :Taxonomy

      def derive_id(id)
        hyraxify("T"+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:"n.user_id"]),
        }
      end
    end
  end
end