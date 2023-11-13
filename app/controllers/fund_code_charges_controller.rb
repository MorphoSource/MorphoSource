class FundCodeChargesController < ApplicationController
  with_themed_layout 'morphosource_dashboard'

  def index
    if current_user.present? || api_request_with_token?
      authorize_user_or_api_token!

      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'morphosource.admin.fund_code_charges.header'), main_app.fund_code_charges_path

      @charges = FundCodeCharge.all
      if start_date.present?
        @charges = @charges.where('start_date >= ?', start_date)
      end
      if end_date.present?
        @charges = @charges.where('end_date <= ?', end_date)
      end

      respond_to do |format|
        format.html
        format.json { render json: @charges }
        format.csv { send_data @charges.to_csv, filename: "charges-#{Date.today}.csv" }
      end
    else
      # user not logged in and no token present for JSON API request
      # redirect to root with Not Found flash if web, or 401 unauthorized by JSON
      respond_to do |format|
        format.html { raise CanCan::AccessDenied }
        format.json { 
          render_json_response(response_type: :unauthorized)
        }
      end
    end
  end

  private

  def search_params
    params[:search] || {}
  end

  def start_date
    @start_date ||= ( params[:start_date] || search_params[:start_date] )
  end

  def end_date
    @end_date ||= ( params[:end_date] || search_params[:end_date] )
  end

  def api_request_with_token?
    request.format.json? && api_token_from_request.present?
  end

  def api_token_from_request
    _, token = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    return token
  end

  def authorize_user_or_api_token!
    if current_user.present?
      authorize! :read, :admin_dashboard
    else
      _, token = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
      raise CanCan::AccessDenied unless request.format.json? && token.present? && auth_api_key(token)
    end
  end

  def auth_api_key(pass)
    u = User.where(token: pass)&.first
    u&.charge_api_user?
  end
end
