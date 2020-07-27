require 'rest-client'
require 'json'

module Morphosource
  module Gbif
    extend ActiveSupport::Autoload

    API_ENDPOINT = 'https://api.gbif.org/v1/species'
    ::RestClient.log = Rails.logger

    def self.search(name, dataset_key, limit = 3)
      response = RestClient.get(
        "#{API_ENDPOINT}",
        { params: { name: name, datasetKey: dataset_key, limit: limit } }
      )
      response.body.force_encoding('utf-8').to_json({content_type: :json, accept: :json})
      JSON.parse(response.body)['results'] if response
    end

    def self.view(key)
      response = RestClient.get "#{API_ENDPOINT}/#{key}"
      JSON.parse(response.body) if response
    end

    def self.dataset_key
      'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c'
    end
  end
end
