module Ms1to2
  module Factories
    module ImagingEventFactoryBehavior
      def process_ie(id, mf, mg)
        ms2_ie_table[id] = ms1to2_model(ms2_ie_model).
          new(id, mg, derive_special_fields_ie(mf, mg)).
          ms2_attributes
      end

      def derive_ie_id(id)
        hyraxify("IE"+id.to_s)
      end

      def derive_special_fields_ie(mf, mg)
        {
          :depositor => derive_depositor(mf[:project_user]),
          :parent_id => derive_ie_parents(mg),
          :ie_modality => derive_ie_modality(mf),
          :power => derive_ie_power(mg)
        }
      end

      def derive_ie_parents(v)
        parents = []
        if v[:specimen_id].present?
          parents << hyraxify("S"+v[:specimen_id].first)
        end
        if v[:scanner_id].present?
          parents << hyraxify("D"+v[:scanner_id].first)
        end
        return parents
      end

      def derive_ie_modality(v)
        v[:modality].first
      end

      def derive_ie_power(v)
        v[:scanner_watts].presence ? [(v[:scanner_watts].first.to_f/1000.0).to_s] : nil
      end
    end
  end
end