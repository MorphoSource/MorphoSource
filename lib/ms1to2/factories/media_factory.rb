module Ms1to2
  module Factories
    class MediaFactory < ObjectFactory
      include Ms1to2::Factories::MediaFactoryBehavior
      include Ms1to2::Factories::ImagingEventFactoryBehavior
      include Ms1to2::Factories::ProcessingEventFactoryBehavior

      self.ms1_table_name = :ms_media_files
      self.ms2_model = :Media

      attr_accessor :ms1_mg_table, :ms2_ie_model, :ms2_pe_model, :ms2_ie_table, :ms2_pe_table

      def initialize(ms1_input_data, ms2_output_data)
        super
        @ms1_mg_table = :ms_media
        @ms2_ie_model = :ImagingEvent
        @ms2_pe_model = :ProcessingEvent
        @ms2_ie_table = {}
        @ms2_pe_table = {}
      end

      def run
        process_table
        output_tables
      end

      def process_table
        ms1_table.each do |k, v|
          id = derive_mf_id(k)
          mg = ms1_input_data.send(ms1_mg_table)[v[:media_id].first]
          process_row(k, v, mg) unless (ms2_table.key?(id) || ms2_output_data.exists?(ms2_model_var(ms2_model), id))    
        end
      end

      def process_row(ms1_id, mf, mg)
        if mf[:file_type].first == '1'
          # raw files, no parent, media and imaging event
          process_media_ie(ms1_id, mf, mg)
        elsif mf[:file_type].first == '2'
          if mf[:derived_from_media_file_id].presence
            # standard child media, media and processing event
            process_media_pe(ms1_id, mf, mg)
          else
            # media with absentee parent, media, imaging, and processing event
            process_media_ie_pe(ms1_id, mf, mg)
          end
        end
      end

      def process_media_ie(ms1_id, mf, mg)
        ie_id = derive_ie_id(ms1_id)
        mf_id = derive_mf_id(ms1_id)

        process_ie(ie_id, mg)
        process_mf(mf_id, mf, mg, ie_id)
      end

      def process_media_pe(ms1_id, mf, mg)
        pe_id        = derive_pe_id(ms1_id)
        pe_parent_id = derive_mf_id(mf[:derived_from_media_file_id].first.to_i.to_s)
        mf_id        = derive_mf_id(ms1_id)

        process_pe(pe_id, mg, pe_parent_id)
        process_mf(mf_id, mf, mg, pe_id)
      end

      def process_media_ie_pe(ms1_id, mf, mg)
        ie_id = derive_ie_id(ms1_id)
        pe_id = derive_pe_id(ms1_id)
        mf_id = derive_mf_id(ms1_id)

        process_ie(ie_id, mg)
        process_pe(pe_id, mg, ie_id)
        process_mf(mf_id, mf, mg, pe_id)
      end

      def output_tables
        # media table
        m_table = ms2_output_data.public_send(ms2_model_var(ms2_model)).merge(ms2_table)
        ms2_output_data.instance_variable_set("@#{ms2_model_var}", m_table)

        # imaging event table
        ie_table = ms2_output_data.public_send(ms2_model_var(ms2_ie_model)).merge(ms2_ie_table)
        ms2_output_data.instance_variable_set("@#{ms2_model_var(ms2_ie_model)}", ie_table)

        # processing event table
        pe_table = ms2_output_data.public_send(ms2_model_var(ms2_pe_model)).merge(ms2_pe_table)
        ms2_output_data.instance_variable_set("@#{ms2_model_var(ms2_pe_model)}", pe_table)
      end
    end
  end
end