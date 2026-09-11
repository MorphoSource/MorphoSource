module Morphosource
  module Solr
    module OrganizationCollection

      def organization_collection?
        self['has_model_ssim'] == ['OrganizationCollection']
      end

      def organization_type
        self['organization_type_ssim']
      end

      def collection_code
        self['collection_code_ssim']
      end

      def institution_code
        self['institution_code_ssim']
      end

      def institution_name
        self['institution_name_ssim']
      end
      alias department institution_name

      def media_ownership_transfer
        self['media_ownership_transfer_bsi']
      end

      def reviews_object_media_downloads
        self['reviews_object_media_downloads_bsi']
      end

      def managers_are_download_reviewers
        value = self['managers_are_download_reviewers_bsi']
        value.nil? ? true : value
      end

      def custom_download_reviewer_users
        self['custom_download_reviewer_users_ssim'] || []
      end

      def recordset_id
        self['recordset_id_ssim']
      end

      # user methods for when the organization collection is standing in for a data owner

      def display_name
        self['display_name_ssi']
      end
      alias name display_name

      def user_key
        self['id']
      end
      alias ms_id user_key

      def proxy_deposit_requests
        ProxyDepositRequest.where(receiving_user_id: id)
      end

      def agreement_attachment_url
        self['agreement_attachment_url_tesim']
      end
    end
  end
end
