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
          :depositor => derive_depositor(v[:user_id]),
          :visibility => derive_visibility(v[:publication_status])
        }
      end

      def derive_visibility(publication_status)
        if Array(publication_status).first.to_i == 0
          return 'restricted'
        elsif Array(publication_status).first.to_i == 1
          return 'open'
        end
      end
    end
  end
end