# Methods to include in catalog controller for REST API authentication of standard methods
module CatalogControllerRestApiBehavior
  extend ActiveSupport::Concern
  include Morphosource::RestApiBehavior

  included do
    before_action :authenticate_api_key_optional, only: :index
    before_action :authenticate_api_key_optional, :enforce_show_permissions, only: [:show, :show_file_metadata]
  end
end
