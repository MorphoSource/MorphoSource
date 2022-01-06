module Ms1to2
  module Factories
    class DeviceFactory < ObjectFactory
      self.ms1_table_name = :ms_scanners
      self.ms2_model = :Device

      def derive_id(id)
        hyraxify('D'+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id]),
          :parent_id => derive_parent_id(v),
          :title => derive_title(v),
          :creator => derive_creator(v),
          :facility => derive_facility(v)
        }
      end

      def derive_parent_id(v)
        inst_id = ms2_output_data.find('f_to_i', v[:facility_id].first, 'organization_id') 
        inst_id ? (inst_id) : ('I' + v[:facility_id].first) 
        hyraxify(inst_id)
      end

      def derive_title(v) # temp method, should grab from spreadsheet later
        [v[:name].first.split(' ', 2)[1]]
      end

      def derive_creator(v)
        [v[:name].first.split(' ', 2)[0]]
      end

      def derive_facility(v)
        ms1_input_data.find(:ms_facilities, v[:facility_id].first, :name)
      end
    end
  end
end