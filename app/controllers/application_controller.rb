module CanCanSkipperFixInheritance
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods
    def inherited(klass)
      super
      klass._cancan_skipper = cancan_skipper.deep_dup
    end
  end
end

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper

  # Fixes a bug in CanCanCan, see https://github.com/CanCanCommunity/cancancan/issues/500
  include CanCanSkipperFixInheritance

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior

  # Adds Hyrax behaviors into the application controller
  include Hyrax::Controller
  include Hyrax::ThemedLayoutController
  with_themed_layout '1_column'

  protect_from_forgery with: :exception

  before_action :set_sitewide_announcement
  before_action :sanitize_sort_param

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

  def sanitize_sort_param
    byebug
    sort_key = params[:sort].presence
    return unless sort_key

    # Blacklight expects params[:sort] to be a key into blacklight_config.sort_fields
    byebug
    unless allowed_sort_parameters.include?(sort_key)
      Rails.logger.warn("Dropping invalid sort param: #{sort_key.inspect}")
      params.delete(:sort)
    end
  end

  protected

  def set_sitewide_announcement
    return unless Hyrax.config.redis_connection

    if (msg = Hyrax.config.redis_connection.get("morphosource:announcement"))
      flash[:alert] = msg.to_s
    elsif (mt = Hyrax.config.redis_connection.get("morphosource:maintenance_time"))
      maint_time = Time.iso8601(mt)
      mins_until = ( ( maint_time - Time.current )/1.minutes ).to_i
      if mins_until >= 0
        flash[:alert] = t("morphosource.base.maintenance_message", minutes: mins_until, time: maint_time)
      else
        Hyrax.config.redis_connection.del("morphosource:maintenance_time")
      end
    end
  end

  def after_sign_in_path_for(resource)
    Rails.application.routes.url_helpers.root_path
  end

  # override to allow additional sort parameters
  def allowed_sort_parameters
    blacklight_config.sort_fields.keys
  end
end
