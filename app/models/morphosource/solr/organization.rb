module Morphosource
  module Solr
    module Organization

      ORGANIZATION_PROPERTIES = %w[contact_person
                                   download_permission
                                   institution_name
                                   license_blank
                                   organization_type
                                   permissions_enforcement_mode
                                   postal_code
                                   recordset_id
                                   rights_holder_blank
                                   rights_statement_blank
                                   team_id]

      def organization?
        self['has_model_ssim'] == ['Organization']
      end

      def agreement_attachment_url
        self['agreement_attachment_url_tesim']
      end

    end
  end
end
