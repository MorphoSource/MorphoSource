module Ms1to2
  module Factories
    class UserFactory < ObjectFactory
      self.ms1_table_name = :ca_users
      self.ms2_model = :User

      def control_vocab_mappings
        ms1to2_model.class_control_vocab_mappings
      end

      def derive_id(id)
        id
      end

      def derive_special_fields(v)
        {
          :display_name => derive_display_name(v[:fname]&.first, v[:lname]&.first),
          :address => derive_address(v[:address1]&.first, v[:address2]&.first), 
          :demographics => derive_profile_multi_field(
            v[:professional_affiliation], 
            v[:professional_affiliation_other]&.first,
            control_vocab_mappings[:demographics]
          ), 
          :software => derive_profile_multi_field(
            v[:visualize_software], 
            v[:visualize_software_other]&.first,
            control_vocab_mappings[:software]
          ), 
          :mesh_file_type => derive_profile_multi_field(
            v[:mesh_filetype], 
            v[:mesh_filetype_other]&.first,
            control_vocab_mappings[:mesh_file_type]
          ), 
          :volume_file_type => derive_profile_multi_field(
            v[:volume_filetype], 
            v[:volume_filetype_other]&.first,
            control_vocab_mappings[:volume_file_type]
          )
        }
      end

      def derive_display_name(fname, lname)
        n = ''
        n += fname if fname
        n += ' ' + lname if lname
      end

      def derive_address(address1, address2)
        n = ''
        n += address1 if address1
        n += ' ' + address2 if address2
      end

      def derive_profile_multi_field(val, val_other, mapping)
        ms2_vals = []
        val = [] if !val.present?
        val.each do |v|        
          ms2_vals << mapping[v] if mapping.key? v
        end
        ms2_vals << val_other if val_other.present?
        return ms2_vals
      end
    end
  end
end