# frozen_string_literal: true

module Morphosource
  # Standard responses following the JSend specification: https://github.com/omniti-labs/jsend
  # See lib/morphosource/gbif.rb for example usage
  module Jsend
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      # type: :success, description: All went well, and (usually) some data was returned.
      # type: :error, description: An error occurred in processing the request, i.e. an exception was thrown.
      # type: :fail, description: There was a problem with the data submitted, or some pre-condition of the API call wasn't satisfied.

      def jsend_success(data)
        {
          status: :success,
          data: data
        }
      end

      def jsend_error(exception = nil, message = nil, code = nil, data = nil)
        response = {
          status: :error,
          message: message || exception.message || exception.default_message || nil
        }
        response.merge!({ code: code }) if code.present?
        response.merge!({ data: data }) if data.present?
        response
      end

      def jsend_fail(data = nil)
        {
          status: :fail,
          data: data
        }
      end
    end
  end
end
