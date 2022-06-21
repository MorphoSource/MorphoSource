require 'rest-client'
require 'json'

module Morphosource
  module IDigBio
    extend ActiveSupport::Autoload

    API_ENDPOINT = 'https://search.idigbio.org/v2'
    ::RestClient.log = Rails.logger

    def self.search(search_query, limit = 100, fields = nil)
      begin
        response = RestClient.post "#{API_ENDPOINT}/search/records/", {rq: search_query, limit: limit }.to_json, {content_type: :json, accept: :json}
      rescue RestClient::Exception => exception
        {
          status: :error,
          message: exception.message || exception.default_message || nil
        }
      else
        {
          status: :success,
          data: JSON.parse(response.body)['items']
        }
      end
    end

    def self.view(uuid)
      begin
        response = RestClient.get "#{API_ENDPOINT}/view/records/#{uuid}"
      rescue RestClient::Exception => exception
        {
          status: :error,
          message: exception.message || exception.default_message || nil
        }
      else
        {
          status: :success,
          data: JSON.parse(response.body)
        }
      end
    end
  end
end
