module Morphosource
  module Collections
    class TeamPresenter < Morphosource::CollectionPresenter

      # attr_reader :organization,

      # :filter_projects,
        # :subcollection_count,
        # :search_form_url,
        # :collection_type_title,
        # :specimens,
      #   :organization_organization_type,
      #   :organization_title,
      #   :organization_institution_name,
      #   :organization_institution_code,
      #   :organization_collection_code,
      #   :organization_recordset_id,
      #   :organization_description,
      #   :organization_related_url,
      #   :organization_address,
      #   :organization_city,
      #   :organization_state_province,
      #   :organization_postal_code,
      #   :organization_country,
      #   :organization_media_count,
      #   :organization_bso_count,
      #   :organization_cho_count

      def organization
        @collection.organization
      end
    end
  end
end
