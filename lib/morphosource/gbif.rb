require 'rest-client'
require 'json'

module Morphosource
  module Gbif
    extend ActiveSupport::Autoload

    API_ENDPOINT = 'https://api.gbif.org/v1'
    ::RestClient.log = Rails.logger

    def self.search(name, dataset_key, limit = 3)
      response = RestClient.get(
        "#{API_ENDPOINT}/species",
        { params: { name: name, datasetKey: dataset_key, limit: limit } }
      )
      response.body.force_encoding('utf-8').to_json({content_type: :json, accept: :json})
      JSON.parse(response.body)['results'] if response
    end

    def self.view(scope, key)
      request_url = "#{API_ENDPOINT}/#{scope}/#{key}"
      begin
        response = RestClient.get request_url
        return JSON.parse(response.body) if response
      rescue RestClient::NotFound => e
        Rails.logger.error("GBIF returned 404 for: #{request_url}")
        return {}
      end
    end

    def self.dataset_key
      'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c'
    end
  end
end
