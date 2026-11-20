module Morphosource
  # Methods to mix in to controllers that allow REST API routes
  #
  # REST API clients authenticate with the Authorization header, using either the user's
  # API key or an OAuth access token from the MorphoSource identity provider (see
  # Morphosource::ApiCredential). Endpoints opt in with `api_auth`:
  #
  #   api_auth :optional, scope: 'api:read',     only: [:index, :show]
  #   api_auth :required, scope: 'api:download', only: :api_generate_download
  #
  # :optional lets the credential add access (e.g. private records the user can see) but
  # still serves anonymous requests. :required rejects requests without a valid credential
  # (or a signed-in session) with 401.
  #
  # API keys work on every api_auth endpoint. OAuth access tokens work only where the
  # declared scope is one the token was granted. Otherwise the response is 403
  # insufficient_scope. `scope: nil` makes an endpoint API-key-only. Invalid, expired or
  # revoked OAuth tokens get 401 invalid_token.
  module RestApiBehavior
    extend ActiveSupport::Concern

    API_AUTH_MODES = %i[optional required].freeze

    included do
      # Declared api_auth rules, kept for introspection (see spec/controllers/api_scopes_spec.rb).
      class_attribute :api_auth_rules, instance_accessor: false, default: []
    end

    class_methods do
      # @param mode [Symbol] :optional or :required
      # @param scope [String, nil] the OAuth scope that grants access, or nil for API-key-only
      # @param filter_options [Hash] before_action options such as only:/except:
      def api_auth(mode, scope:, **filter_options)
        raise ArgumentError, "api_auth mode must be one of #{API_AUTH_MODES.inspect}" unless API_AUTH_MODES.include?(mode)

        scope = scope&.to_s
        if scope && !RestApiBehavior.api_scopes.include?(scope)
          raise ArgumentError, "Unknown API scope '#{scope}'. Add it to optional_scopes in config/initializers/doorkeeper.rb."
        end

        self.api_auth_rules = api_auth_rules + [{
          mode: mode,
          scope: scope,
          only: Array(filter_options[:only]).map(&:to_sym),
          except: Array(filter_options[:except]).map(&:to_sym)
        }]

        # A block, not a symbol, so declarations for different actions never replace each
        # other (Rails drops an earlier symbol callback when the same symbol is redeclared).
        before_action(**filter_options) do |controller|
          controller.send(:authenticate_api, required: mode == :required, scope: scope)
        end
      end
    end

    # The 'api:*' scopes configured in Doorkeeper.
    def self.api_scopes
      Doorkeeper.config.optional_scopes.to_a.grep(/\Aapi:/)
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
          }, status: code
       else
        render json: {
            code: code, 
            message: message,
            description: description
          }, status: code
       end
    end

    private

      def api_credential
        Morphosource::ApiCredential.from_env(request.env)
      end

      def authenticate_api(required:, scope:)
        credential = api_credential
        if credential.oauth?
          return deny_invalid_oauth_token unless credential.valid_oauth_token?
          return deny_insufficient_oauth_scope(scope) unless credential.includes_scope?(scope)
        end

        user = warden.authenticate(:oauth_token, :api_key)
        deny_access_unauthorized if required && user.nil?
      end

      def deny_invalid_oauth_token
        render_oauth_error :unauthorized, 'invalid_token', 'The access token is invalid, expired or revoked.'
      end

      def deny_insufficient_oauth_scope(scope)
        description =
          if scope
            "This request requires an access token with the '#{scope}' scope."
          else
            'This endpoint does not accept OAuth access tokens. Use an API key instead.'
          end
        render_oauth_error :forbidden, 'insufficient_scope', description, scope
      end

      # Error response for OAuth bearer tokens, per RFC 6750 section 3.
      def render_oauth_error(status, error, description, scope = nil)
        challenge = %(Bearer realm="MorphoSource", error="#{error}", error_description="#{description}")
        challenge += %(, scope="#{scope}") if scope
        response.headers['WWW-Authenticate'] = challenge

        code = Rack::Utils.status_code(status)
        render json: {
          code: code,
          message: Rack::Utils::HTTP_STATUS_CODES[code],
          description: description,
          error: error
        }, status: status
      end
  end
end