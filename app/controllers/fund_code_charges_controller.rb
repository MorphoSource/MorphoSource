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
          render json: {
            code: 401,
            message: 'Authorization Required',
            description: 'You must provide API authorization key with HTTP request header field X-API-KEY to do that'
          }
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
    if request.format.json? && !current_user.admin?
      authorize_api_request
    else
      authorize! :read, :admin_dashboard
    end
  end

  def authorize_api_request
    request.headers["HTTP_X_API_KEY"].present? && auth_api_key
  end

  def auth_api_key
    u = User.where(token: request.headers["HTTP_X_API_KEY"])&.first
    u&.charge_api_user?
  end
end
