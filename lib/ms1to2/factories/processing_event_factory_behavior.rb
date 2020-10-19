module Ms1to2
  module Factories
    module ProcessingEventFactoryBehavior
      def process_pe(id, mf, mg, parent_id)
        ms2_pe_table[id] = ms1to2_model(ms2_pe_model).
          new(id, mg, derive_special_fields_pe(mf, parent_id)).
          ms2_attributes
      end

      def derive_pe_id(id)
        hyraxify("PE"+id.to_s)
      end

      def derive_special_fields_pe(v, parent_id)
        {
          :depositor => derive_depositor(v[:project_user])
        }
      end
    end
  end
end