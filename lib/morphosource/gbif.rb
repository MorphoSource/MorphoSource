# frozen_string_literal: true

require 'rest-client'
require 'json'

module Morphosource
  # Methods for searching the GBIF API
  # https://www.gbif.org/developer/summary
  module Gbif
    extend ActiveSupport::Autoload
    # include JSend responses
    include Morphosource::Jsend

    API_ENDPOINT = 'https://api.gbif.org/v1'
    ::RestClient.log = Rails.logger

    def self.search(name, dataset_key, limit = 3)
      request_url = "#{API_ENDPOINT}/species"
      params = { name: name, datasetKey: dataset_key, limit: limit }
      search_gbif(request_url, params)
    end

    def self.view(key, scope = 'species')
      request_url = "#{API_ENDPOINT}/#{scope}/#{key}"
      search_gbif(request_url)
    end

    def self.search_gbif(request_url, params = {})
      response = execute_request(request_url, params)
      process_response(response)
    rescue RestClient::BadRequest => e
      RestClient.log.error("GBIF returned #{e.message} for #{request_url}")
      jsend_fail({ 'message' => e.message, 'request_url' => request_url, 'params' => params })
    rescue StandardError => e
      RestClient.log.error("GBIF returned #{e.message} for #{request_url}")
      jsend_error(e)
    end

    def self.execute_request(request_url, params)
      RestClient::Request.execute(method: 'get',
                                  url: request_url,
                                  headers: { params: params },
                                  timeout: 15)
    end

    def self.process_response(response)
      return jsend_fail("Response code: #{response.code}") unless response.code == 200

      data = parse_response(response)
      jsend_success(data)
    rescue  StandardError => e
      jsend_error(e, 'Response.body parsing failed.')
    end

    def self.parse_response(response)
      force_encoding(response)
      json = JSON.parse(response.body)
      json['results'] || json
    end

    def self.force_encoding(response)
      response.body.force_encoding('utf-8').to_json({ content_type: :json, accept: :json })
    end

    def self.dataset_key
      'd7dddbf4-2cf0-4f39-9b2a-bb099caae36c'
    end
  end
end
