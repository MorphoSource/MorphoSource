require 'rest-client'
require 'json'

module IDigBio
  extend ActiveSupport::Autoload

  API_ENDPOINT = 'https://search.idigbio.org/v2'
  ::RestClient.log = Rails.logger

  def self.search(search_query, limit = 500, fields = nil)
    response = RestClient.post "#{API_ENDPOINT}/search/records/", {rq: search_query, limit: limit}.to_json, {content_type: :json, accept: :json}
    JSON.parse(response.body)['items'] if response
  end
end
