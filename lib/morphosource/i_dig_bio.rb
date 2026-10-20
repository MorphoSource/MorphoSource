require 'rest-client'
require 'json'

module Morphosource
  module IDigBio
    extend ActiveSupport::Autoload

    API_ENDPOINT = 'https://search.idigbio.org/v2'
    DEFAULT_TIMEOUT = 60
    ::RestClient.log = Rails.logger

    def self.search(search_query, limit = 100, fields = nil, timeout: DEFAULT_TIMEOUT)
      begin
        response = RestClient::Request.execute(method: :post,
                                               url: "#{API_ENDPOINT}/search/records/",
                                               payload: { rq: search_query, limit: limit }.to_json,
                                               headers: { content_type: :json, accept: :json },
                                               timeout: timeout)
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

    def self.view(uuid, timeout: DEFAULT_TIMEOUT)
      begin
        response = RestClient::Request.execute(method: :get, url: "#{API_ENDPOINT}/view/records/#{uuid}", timeout: timeout)
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
