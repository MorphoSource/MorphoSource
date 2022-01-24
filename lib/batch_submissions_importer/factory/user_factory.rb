module BatchSubmissionsImporter
  module Factory
    class UserFactory < ObjectFactory
      include WithAssociatedCollection

      self.klass = User

      def self.prepare_attributes(attrs)
      	array_fields = [:demographics, :intent, :software, :mesh_file_type, 
      					:volume_file_type, :printer_model, :printer_file]

      	attrs = attrs.map { |k, v| [k, array_fields.include?(k) ? v : Array(v).first ] }.to_h
      	attrs[:id] = attrs[:id].to_i
      	attrs[:ms_id] = attrs[:ms_id].to_s
      	attrs[:ms1_user] = true
      	attrs[:password] = SecureRandom.hex

      	return attrs
      end

    end
  end
end
