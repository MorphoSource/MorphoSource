# Methods to include in catalog controller for REST API authentication of standard methods
module CatalogControllerRestApiBehavior
  extend ActiveSupport::Concern
  include Morphosource::RestApiBehavior

  included do
    api_auth :optional, scope: 'api:read', only: [:index, :show, :show_file_metadata]
    # Redeclared after api_auth so it runs once the API user is known.
    before_action :enforce_show_permissions, only: [:show, :show_file_metadata]
  end
end
