require 'rest-client'
require 'json'

module IDigBio
  extend ActiveSupport::Autoload

  API_ENDPOINT = 'https://search.idigbio.org/v2'

  def self.search(search_query, limit = 500, fields = nil)
    response = RestClient.get "#{API_ENDPOINT}/search/records/", {params: {rq: search_query, limit: limit}}
    JSON.parse(response.body)['items'] if response
  end
end
