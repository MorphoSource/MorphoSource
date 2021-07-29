require 'rest-client'
require 'json'

module Morphosource
  class PackratApi
    extend ActiveSupport::Autoload

    attr_accessor :short_lived_token

    ENDPOINT_CLIENT_ID = Hyrax.config.packrat_api_endpoint_client_id
    SERVICE_URL = Hyrax.config.packrat_api_service_url
    OIDC_LONG_LIVED_TOKEN = Hyrax.config.packrat_api_oidc_long_lived_token
    IDMS_TOKEN_EXCHANGE_URL = Hyrax.config.packrat_api_idms_token_exchange_url
    ENDPOINT = Hyrax.config.packrat_api_endpoint
    VOLUME_ID = Hyrax.config.packrat_api_volume_id
    ::RestClient.log = Rails.logger

    def self.get_volume_details
      new.get_volume_details
    end

    def initialize
      generate_short_lived_token
    end

    def generate_short_lived_token
      short_lived_data = {
        longLivedToken: OIDC_LONG_LIVED_TOKEN,
        clientId: ENDPOINT_CLIENT_ID,
        endpoints: ["endpoint:#{ENDPOINT}"]
      }

      response = RestClient.post(
        IDMS_TOKEN_EXCHANGE_URL,
        short_lived_data.to_json,
        {content_type: :json, accept: :json}
      )

      if response.code == 201 || response.code == 200
        begin
          @short_lived_token = JSON.parse(response.body)['mapQueryResult']['attributes']['accessToken']
        rescue => error
          raise "Request to generate short lived token completed successfully, but response processing failed: #{error.message}"
        end
      else
        raise "Request to generate short lived token was not successful, response body was #{JSON.parse(response.body)}"
      end

      if !short_lived_token.present?
        raise "Request to generate short lived token completed successfully, but token is not present. Token is #{short_lived_token} and response body was #{JSON.parse(response.body)}"
      end
    end

    def get_volume_details
      response = RestClient.get(
        "#{SERVICE_URL}#{ENDPOINT}/volumes/#{VOLUME_ID}",
        :Authorization => short_lived_token
      )

      if response.code == 200
        volume_data = JSON.parse(response.body)
        max_gb = volume_data['max_gb'].to_i
        annual_price_rate_per_gb = volume_data['annual_cost_per_gb'].to_d
        if max_gb.present? && annual_price_rate_per_gb.present?
          monthly_price_rate_per_gb = annual_price_rate_per_gb / 12
          return {
            status: 'success',
            data: {
              billing_rate: monthly_price_rate_per_gb,
              billing_unit: 'gb',
              period: 'month',
              total_storage: max_gb,
            }
          }
        else
          raise "Request to Packrat API was successful, but annual_cost_per_gb and max_gb attributes not present. Response body was #{JSON.parse(response.body)}"
        end
      else
        raise "Request to Packrat API was not successful, response body was #{JSON.parse(response.body)}"
      end

      return {
        status: 'failure',
        message: 'Unexpected error occurred retrieving volume details from Packrat API'
      }
    end

  end
end