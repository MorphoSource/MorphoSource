module Ms1to2
  module Factories
    class ObjectFactory
      class_attribute :ms1_table_name, :ms2_model
      attr_accessor :ms1_table, :ms2_table, :ms1_input_data, :ms2_output_data

      def initialize(ms1_input_data, ms2_output_data)
        @ms1_table = ms1_input_data.public_send(ms1_table_name)
        @ms2_table = {}
        @ms1_input_data = ms1_input_data
        @ms2_output_data = ms2_output_data
      end

      def run
        process_table
        output_table
      end

      # Can be overwritten
      def process_table
        ms1_table.each do |k, v|
          id = derive_id(k)
          process_row(id, v) unless (ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var, id))
          #process_row(id, v) unless (ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var, id))
        end 
      end

      # Can be overwritten
      def process_row(id, v)
        ms2_table[id] = ms1to2_model.new(id, v, derive_special_fields(v)).ms2_attributes
      end

      def output_table(m=ms2_model, t=ms2_table)
        t = ms2_output_data.public_send(ms2_model_var(m)).merge(t)
        ms2_output_data.instance_variable_set("@#{ms2_model_var(m)}", t)
      end

      # Can be overwritten
      def derive_id(id)
        hyraxify(id)
      end

      def hyraxify(id)
        if id.length < 9
          id = id + 'x' + "0"*(8-id.length)
        else
          id
        end
      end

      # Can be overwritten
      def derive_special_fields(v)
        {}
      end

      def derive_depositor(user_id)
        ms1_input_data.find(:ca_users, Array(user_id).first, :email).first
      end

      def derive_collection_id(project_id)
        Array(project_id).map { |id| hyraxify("C"+id) }
      end

      def ms1to2_model(m=ms2_model)
        "Ms1to2::Models::#{m}".constantize
      end

      def model(m=ms2_model)
        "#{m}".constantize
      end

      def ms2_model_var(m=ms2_model)
        m.to_s.underscore
      end
    end
  end
end