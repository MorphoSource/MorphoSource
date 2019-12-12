module Ms1to2
  module Models
    class BaseObject
      attr_reader :ms1_attributes, :ms2_attributes, :special_fields

      def initialize(id, ms1_attributes, special_fields={})
        @ms2_attributes = { :id => id }
        @ms1_attributes = ms1_attributes
        @special_fields = special_fields
        map_attributes
        add_special_fields
        ms2_attributes
      end

      def map_attributes
        mappings.each do |ms1_k, ms2_k|
          if ms1_attributes.key?(ms1_k)
            if control_vocab_mappings.key?(ms1_k) 
              ms2_attributes[ms2_k] = map_cv(ms1_k, ms1_attributes[ms1_k])
            else
              ms2_attributes[ms2_k] = ms1_attributes[ms1_k]
            end 
          end
        end
      end

      def map_cv(k, v)
        v.map {|sub_v| control_vocab_mappings[k][sub_v]}
      end

      def add_special_fields
        special_fields.each do |k, v|
          ms2_attributes[k] = v if expected_special_fields.include?(k)
        end
      end

      # This should be overwritten
      def mappings
        {}
      end

      # This should be overwritten
      def control_vocab_mappings
        {}
      end

      # This should be overwritten
      def expected_special_fields
        []
      end
    end
  end
end