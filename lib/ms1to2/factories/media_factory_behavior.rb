module Ms1to2
  module Factories
    module MediaFactoryBehavior
      def process_mf(id, mf, mg, parent_id)
        ms2_table[id] = ms1to2_model(ms2_model).
          new(id, mf, derive_special_fields_mf(mf, mg, parent_id)).
          ms2_attributes
      end

      def derive_mf_id(id)
        hyraxify(id.to_s)
      end

      def derive_special_fields_mf(mf, mg, parent_id)
        {
          :depositor => derive_depositor(mf[:project_user]),
          :parent_id => parent_id,
          :part => derive_part(mf, mg),
          :side => derive_side(mf, mg),
          :description => derive_description(mf, mg),
          :cite_as => derive_cite_as(mg),
          :available => derive_available(mf, mg),
          :unit => derive_unit(mg),
          :funding => derive_funding(mg),
          :license => derive_license(mg),
          :rights_statement => derive_rights_statement(mg),
          :rights_holder => derive_rights_holder(mg),
          :x_spacing => derive_x_spacing(mg),
          :y_spacing => derive_y_spacing(mg),
          :z_spacing => derive_z_spacing(mg),
          :modality => derive_modality(mf),
          :visibility => derive_visibility(mf, mg),
          :fileset_visibility => derive_fileset_visibility(mf, mg),
          :fileset_accessibility => derive_fileset_accessibility(mf, mg),
          :morphosource_use_agreement_type => ['Standard'], 
          :required_archival_of_published_derivatives => ['OnMorphoSource'],
          :permits_commercial_use => ['CommercialUseNotPermitted'], 
          :permits_3d_use => ['3DPrintingLimited'],
          :media_type => derive_media_type(mf)
        }
      end

      def derive_media_type(mf)
        if mf[:media].present?
          if File.extname(mf[:media]&.first).downcase == '.zip'
            ['CTImageSeries']
          else
            ['Mesh']
          end
        else
          []
        end
      end

      def derive_depositor(user_id)
        Array(user_id).first
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

      def derive_funding(mg)
        mg[:grant_support]
      end

      def derive_license(mg)
        val = mg[:copyright_license]
        [mf_control_vocab_mappings[:copyright_license][val.first]] if val.presence
      end

      def derive_rights_statement(mg)
        if mg[:is_copyrighted]&.first.to_i == 1
          ['http://rightsstatements.org/vocab/InC/1.0/']
        else
          case mg[:copyright_permission]&.first
          when '4'
            ['http://rightsstatements.org/vocab/NKC/1.0/']
          when '5'
            ['http://rightsstatements.org/vocab/CNE/1.0/']
          else
            []
          end
        end
      end

      def derive_rights_holder(mg)
        mg[:copyright_info]
      end

      def derive_x_spacing(mg)
        mg[:scanner_x_resolution]
      end

      def derive_y_spacing(mg)
        mg[:scanner_y_resolution]
      end

      def derive_z_spacing(mg)
        mg[:scanner_z_resolution]
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
            '1' => 'http://creativecommons.org/publicdomain/zero/1.0/',
            '2' => 'https://creativecommons.org/licenses/by/4.0/',
            '3' => 'https://creativecommons.org/licenses/by-nc/4.0/',
            '4' => 'https://creativecommons.org/licenses/by-sa/4.0/',
            '5' => 'https://creativecommons.org/licenses/by-nc-sa/4.0/',
            '6' => 'https://creativecommons.org/licenses/by-nd/4.0/',
            '7' => 'https://creativecommons.org/licenses/by-nc-nd/4.0/'
          }
        }
      end

      def derive_modality(mf)
        mf[:modality]
      end

      def ms1_publication_code(mf, mg)
        # 2 is restricted download, 1 is open, 0 is private
        mf_p = mf[:published]&.first
        mg_p = mg[:published]&.first
        if mf_p.present?
          mf_p.to_i
        elsif mg_p.present?
          mg_p.to_i
        else
          0
        end
      end

      def public
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end

      def private
        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
      end

      def derive_visibility(mf, mg)
        case ms1_publication_code(mf, mg)
          when 2
            public
          when 1
            public
          else
            private
        end
      end

      def derive_fileset_visibility(mf, mg)
        ''
      end

      def derive_fileset_accessibility(mf, mg)
        case ms1_publication_code(mf, mg)
          when 2
            'restricted_download'
          when 1
            'open'
          else
            'private'
        end
      end

    end
  end
end