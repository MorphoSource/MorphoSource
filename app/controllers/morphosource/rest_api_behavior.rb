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

    def render_json_by_http_code(code, errors = nil)
      case code
      when 401
        status = :not_authenticated
        message = "Authentication Required"
        description = "You must be logged in to do that!"
      when 404
        status = :not_found
        message = "Not Found"
        description = "Resource not found or unavailable."
      when 400
        status = :bad_request
        message = "Bad Request"
        description = "Cannot or will not process request due to perceived client error in request." 
      end
      if errors.present?
        render json: {
            code: code, 
            message: message,
            description: description,
            errors: errors
          }, status: status
       else
        render json: {
            code: code, 
            message: message,
            description: description
          }, status: status
       end
    end

  end
end