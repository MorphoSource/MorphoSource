module Ms1to2
  module Factories
    class OrganizationFactory < ObjectFactory
      self.ms1_table_name = :ms_organizations
      self.ms2_model = :Organization

      def process_table
        super
        process_facility_table
        output_table
      end

      def process_facility_table
        ms1_input_data.public_send(:ms_facilities).each do |k, v|
          id = derive_facility_id(k)
          if ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var, id)
            next
          elsif matching_organization(v[:organization].first)
            add_organization_match(k, matching_organization(v[:organization].first))
          else
            process_facility_row(id, v)
            add_organization_match(k, id)
          end
        end
      end

      def process_facility_row(id, v)
        ms2_table[id] = ms1to2_model(:OrganizationFromFacility).new(
          id, v, derive_special_fields(v)).ms2_attributes
      end

      def matching_organization(organization_name)
        if ms2_output_data.find_ids(ms2_model_var, :title, organization_name).first
          ms2_output_data.find_ids(ms2_model_var, :title, organization_name).first
        else
          ms2_table.each do |k, v|
            return k if v.key?(:title) && v[:title] == organization_name
          end
          nil
        end
      end

      def add_organization_match(facility_id, organization_id)
        t = ms2_output_data.public_send('f_to_i').merge(
          { facility_id => { 'facility_id' => facility_id, 'organization_id' => organization_id } }
        )
        ms2_output_data.instance_variable_set("@f_to_i", t)
      end

      def derive_id(id)
        hyraxify('I'+id.to_s)
      end

      def derive_facility_id(id)
        hyraxify('IF'+id.to_s)
      end

      def derive_special_fields(v)
        {
          :depositor => derive_depositor(v[:user_id])
        }
      end
    end
  end
end