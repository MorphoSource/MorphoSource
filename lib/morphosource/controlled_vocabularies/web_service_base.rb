# ::Qa::Authorities::WebServiceBase
module Morphosource
  module ControlledVocabularies
    module WebServiceBase

      attr_accessor :raw_response

      def find(id)
        json(find_url(id))
      end

      ##
      # Make a web request & retieve a JSON response for a given URL.
      #
      # @param url [String]
      # @return [Hash] a parsed JSON response
      def json(url)
        begin
          response = response(url)
        rescue => exception
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

      ##
      # Make a web request and retrieve the response.
      #
      # @param url [String]
      # @return [Faraday::Response]
      def response(url)
        Faraday.get(url) { |req| req.headers['Accept'] = 'application/json' }
      end

    end
  end
end
