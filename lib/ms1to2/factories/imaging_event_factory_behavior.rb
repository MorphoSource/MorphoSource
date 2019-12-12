module Ms1to2
  module Factories
    module ImagingEventFactoryBehavior
      def process_ie(id, mg)
        ms2_ie_table[id] = ms1to2_model(ms2_ie_model).
          new(id, mg, derive_special_fields_ie(mg)).
          ms2_attributes
      end

      def derive_ie_id(id)
        hyraxify("IE"+id.to_s)
      end

      def derive_special_fields_ie(v)
        {
          :depositor => derive_depositor(v[:user_id]),
          :parent_id => derive_ie_parents(v),
          :ie_modality => derive_ie_modality(v),
          :power => derive_ie_power(v)
        }
      end

      def derive_ie_parents(v)
        [hyraxify("S"+v[:specimen_id].first), hyraxify("D"+v[:scanner_id].first)]
      end

      def derive_ie_modality(v)
        device_id = hyraxify("D"+v[:scanner_id].first)
        ms2_output_data.find(ms2_model_var(:Device), device_id, :modality)
      end

      def derive_ie_power(v)
        v[:scanner_watts].presence ? [(v[:scanner_watts].first.to_f/1000.0).to_s] : nil
      end
    end
  end
end