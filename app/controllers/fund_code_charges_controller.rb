class FundCodeChargesController < ApplicationController
  with_themed_layout 'morphosource_dashboard'

  def index
    if require_permissions
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
      respond_to do |format|
        format.json { 
          render_json_response(response_type: :forbidden)
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

  def require_permissions
    request.format.json? ? authorize_api_request : authorize!(:read, :admin_dashboard)
  end

  def authorize_api_request
    if current_user.present?
      authorize! :read, :admin_dashboard
    else
      user, pass = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
      pass.present? && auth_api_key(pass)
    end
  end

  def auth_api_key(pass)
    u = User.where(token: pass)&.first
    u&.charge_api_user?
  end
end
