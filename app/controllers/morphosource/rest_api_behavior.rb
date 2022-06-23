module Morphosource
  # Methods to mix in to controllers that allow REST API routes
  module RestApiBehavior
    def authenticate_api_key_optional
      warden.authenticate(:api_key)
    end

    def authenticate_api_key_required
      warden.authenticate!(:api_key)
    end

    def deny_access_forbidden
      request.format = 'json' if request.format == 'csv'
      respond_to do |format|
        format.json { render_json_response(response_type: :forbidden) }
        format.any { render 'hyrax/base/unauthorized', status: :forbidden }
      end
    end

    def deny_access_unauthorized
      request.format = 'json' if request.format == 'csv'
      respond_to do |format|
        format.json { render_json_response(response_type: :unauthorized) }
        format.any { render 'hyrax/base/unauthorized', status: :unauthorized }
      end
    end
  end
end