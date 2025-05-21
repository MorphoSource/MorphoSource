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

  before_action :set_sitewide_announcement
  # before_action :set_sitewide_banner

  # Blacklight discarding flash messages - see https://github.com/samvera/hyrax/issues/1596
  skip_after_action :discard_flash_if_xhr

  rescue_from CanCan::AccessDenied, ActiveFedora::ObjectNotFoundError, Ldp::Gone do |exception|
    respond_to do |format|
      format.json {
        render json: { code: 404, message: t("cancan.not_found.message"), description: t("cancan.not_found.description")}, status: :not_found
      }
      format.html { redirect_to main_app.root_url, notice: "#{t("cancan.not_found.message")}: #{t("cancan.not_found.description")}" }
      format.js   { render nothing: true, status: :not_found }
      format.any  { redirect_to main_app.root_url, notice: "#{t("cancan.not_found.message")}: #{t("cancan.not_found.description")}" }
    end
  end

  protected

  def set_sitewide_announcement
    return unless Redis.current

    if (msg = Redis.current.get("morphosource:announcement"))
      flash[:alert] = msg.to_s
    elsif (mt = Redis.current.get("morphosource:maintenance_time"))
      maint_time = Time.iso8601(mt)
      mins_until = ( ( maint_time - Time.current )/1.minutes ).to_i
      if mins_until >= 0
        flash[:alert] = t("morphosource.base.maintenance_message", minutes: mins_until, time: maint_time)
      else
        Redis.current.del("morphosource:maintenance_time")
      end
    end
  end

  # def set_sitewide_banner
  #   @sitewide_banner = ContentBlock.find_by(name: "display_sitewide_banner")&.value
  #   @sitewide_banner_text = ContentBlock.find_by(name: "sitewide_banner_text")&.value
  # end

  def after_sign_in_path_for(resource)
    Rails.application.routes.url_helpers.root_path
  end
end
