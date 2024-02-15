module Morphosource
  module Collections
    class OrganizationPresenter < Morphosource::CollectionPresenter

      delegate :organization_type, :collection_code, :institution_code, :institution_name, :recordset_id, to: :solr_document

      def edit_path
        Rails.application.routes.url_helpers.organization_edit_path(id, locale: I18n.locale)
      end

      def collection_type_title
        "Organization"
      end

      def organization
        @collection
      end

      def object_media_count
        Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_organization_id_ssim:#{id}").count
      end

      def device_media_count
        Morphosource::SolrService.new.get_docs("has_model_ssim:Media AND media_device_facility_organization_id_ssim:#{id}").count
      end

    end
  end
end