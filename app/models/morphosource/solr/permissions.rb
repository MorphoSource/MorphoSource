module Morphosource
  module Solr
    module Permissions

      # properties shared by media and organizations
      PERMISSIONS_PROPERTIES = %w[agreement_uri
                                 download_reviewer
                                 morphosource_use_agreement_type
                                 permits_3d_use
                                 permits_commercial_use
                                 preview_mode
                                 required_archival_of_published_derivatives
                                 rights_holder].freeze

    end
  end
end
