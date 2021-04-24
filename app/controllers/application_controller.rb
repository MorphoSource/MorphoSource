class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  # Blacklight discarding flash messages - see https://github.com/samvera/hyrax/issues/1596
  skip_after_action :discard_flash_if_xhr

  protected

  def after_sign_in_path_for(resource)
    Rails.application.routes.url_helpers.root_path
  end
end
