module Morphosource
  module Collections
    class OrganizationPresenter < Morphosource::CollectionPresenter

      delegate :address,
               :agreement_uri,
               :city,
               :collection_code,
               :contact_person,
               :country,
               :download_permission,
               :download_reviewer,
               :institution_code,
               :institution_name,
               :morphosource_use_agreement_type,
               :organization_type,
               :permissions_enforcement_mode,
               :permits_commercial_use,
               :permits_3d_use,
               :postal_code,
               :preview_mode,
               :recordset_id,
               :required_archival_of_published_derivatives,
               :rights_holder,
               :rights_statement,
               :state_province,
               to: :solr_document

      def edit_path
        Rails.application.routes.url_helpers.organization_edit_path(id, locale: I18n.locale)
      end

      def collection_type_title
        "Organization"
      end

      def media_ownership_transfer
        solr_document.media_ownership_transfer.to_s
      end

      def organization
        @collection
      end

      def object_media_count
        Morphosource::SolrService.new.get_count("has_model_ssim:Media AND media_organization_id_ssim:#{id}")
      end

      def device_media_count
        Morphosource::SolrService.new.get_count("has_model_ssim:Media AND media_device_facility_organization_id_ssim:#{id}")
      end

      def attachment_url
        @attachment_url ||= get_attachment("agreement")
      end

      private

      def get_attachment(field, work_id = id)
        Morphosource::AttachmentService.get(work_id, field).present? ?
        [Rails.application.routes.url_helpers.attachment_path(id: work_id, field: field)] :
        []
      end

    end
  end
end