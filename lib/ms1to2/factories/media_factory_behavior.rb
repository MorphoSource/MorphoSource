module Ms1to2
  module Factories
    module MediaFactoryBehavior
      def process_mf(id, mf, mg, parent_id)
        ms2_table[id] = ms1to2_model(ms2_model).
          new(id, mf, derive_special_fields_mf(mf, mg, parent_id)).
          ms2_attributes
      end

      def derive_mf_id(id)
        hyraxify("M"+id.to_s)
      end

      def derive_special_fields_mf(mf, mg, parent_id)
        {
          :depositor => derive_depositor(mf[:user_id]),
          :parent_id => parent_id,
          :collection_id => derive_collection_id(mg[:project_id]),
          :part => derive_part(mf, mg),
          :side => derive_side(mf, mg),
          :description => derive_description(mf, mg),
          :cite_as => derive_cite_as(mg),
          :available => derive_available(mf, mg),
          :unit => derive_unit(mg),
          :funding_attribution => derive_funding_attribution(mg),
          :license => derive_license(mg),
          :rights_holder => derive_rights_holder(mg),
          :x_spacing => derive_x_spacing(mg),
          :y_spacing => derive_y_spacing(mg),
          :z_spacing => derive_z_spacing(mg),
          :modality => derive_modality(mg),
          :visibility => derive_visibility(mf, mg)
        }
      end

      def derive_part(mf, mg)
        mf[:element].presence || mg[:element].presence || []
      end

      def derive_side(mf, mg)
        val = mf[:side].presence || mg[:side].presence || []
        [mf_control_vocab_mappings[:side][val.first]] if val.presence
      end

      def derive_description(mf, mg)
        val = ''
        val += ('Migrated MorphoSource 1 Media File Title: ' + mf[:title].first + ' ') if mf[:title].presence
        val += ('Migrated MorphoSource 1 Media Group Title: ' + mg[:title].first + ' ') if mg[:title].presence
        val += ('Migrated MorphoSource 1 Media File Description: ' + mf[:notes].first + ' ') if mf[:notes].presence
        val += ('Migrated MorphoSource 1 Media Group Description: ' + mg[:notes].first) if mg[:notes].presence
        [val]
      end

      def derive_cite_as(mg)
        val = ''
        val += ('Migrated MorphoSource 1 Media Citation Instructions: ' + mg[:media_citation_instruction1].first + ' provided access to these data') if mg[:media_citation_instruction1].presence
        val += (mg[:media_citation_instruction2].first) if mg[:media_citation_instruction2].presence
        val += (' ' + mg[:media_citation_instruction3].first) if mg[:media_citation_instruction3].presence
        val += ('. The files were downloaded from www.MorphoSource.org, Duke University.') if mg[:media_citation_instruction1].presence
        [val]
      end

      def derive_available(mf, mg)
        mf[:published_on].presence || mg[:published_on].presence || []
      end

      def derive_unit(mg)
        (derive_x_spacing(mg) || derive_y_spacing(mg) || derive_z_spacing(mg)) ? ["Mm"] : []
      end

      def derive_funding_attribution(mg)
        mg[:grant_support]
      end

      def derive_license(mg)
        val = mg[:copyright_license]
        [mf_control_vocab_mappings[:copyright_license][val.first]] if val.presence
      end

      def derive_rights_holder(mg)
        mg[:copyright_info]
      end

      def derive_x_spacing(mg)
        mg[:scanner_x_resolution]
      end

      def derive_y_spacing(mg)
        mg[:scanner_x_resolution]
      end

      def derive_z_spacing(mg)
        mg[:scanner_x_resolution]
      end

      def mf_control_vocab_mappings
        {
          :side => {
            'LEFT' => 'Left',
            'RIGHT' => 'Right',
            'MIDLINE' => 'Midline',
            'NA' => 'NotApplicable',
            'UNKNOWN' => 'Unknown'
          },
          :copyright_license => {
            1 => 'http://creativecommons.org/publicdomain/zero/1.0/',
            2 => 'https://creativecommons.org/licenses/by/4.0/',
            3 => 'https://creativecommons.org/licenses/by-nc/4.0/',
            4 => 'https://creativecommons.org/licenses/by-sa/4.0/',
            5 => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
            6 => 'https://creativecommons.org/licenses/by-nd/4.0/',
            7 => 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
          }
        }
      end

      def derive_modality(mg)
        device_id = hyraxify('D' + mg[:scanner_id]&.first)
        if 'Device'.constantize.exists?(device_id)
          'Device'.constantize.find(device_id).modality&.first
        else
          ms2_output_data.public_send('device')[device_id][:modality]&.first
        end
      end

      def derive_visibility(mf, mg)
        mf_p = mf[:published]&.first
        mg_p = mg[:published]&.first
        (mf_p && mf_p.to_i > 0) || (!mf_p && mg_p && mg_p.to_i > 0) ? 'open' : 'restricted'
      end
    end
  end
end