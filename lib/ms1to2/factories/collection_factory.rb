module Ms1to2
  module Factories
    class CollectionFactory < ObjectFactory
      self.ms1_table_name = :ms_projects
      self.ms2_model = :Collection

      def derive_id(id)
        hyraxify("C"+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id])
        }
      end
    end
  end
end