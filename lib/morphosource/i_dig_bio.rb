require 'rest-client'
require 'json'

module Morphosource
  module IDigBio
    extend ActiveSupport::Autoload

    API_ENDPOINT = 'https://search.idigbio.org/v2'
    ::RestClient.log = Rails.logger

    def self.search(search_query, limit = 100, fields = nil)
      response = RestClient.post "#{API_ENDPOINT}/search/records/", {rq: search_query, limit: limit}.to_json, {content_type: :json, accept: :json}
      JSON.parse(response.body)['items'] if response
    end

    def self.view(uuid)
      response = RestClient.get "#{API_ENDPOINT}/view/records/#{uuid}"
      JSON.parse(response.body) if response
    end
  end
end
