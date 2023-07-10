# frozen_string_literal: true

module Morphosource
  # Standard responses following the JSend specification: https://github.com/omniti-labs/jsend
  # See lib/morphosource/gbif.rb for example usage
  module Jsend
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def jsend_success(data)
        {
          status: :success,
          data: data
        }
      end

      def jsend_error(exception, message = nil)
        {
          status: :error,
          message: message || exception.message || exception.default_message || nil
        }
      end

      def jsend_fail(message = nil)
        {
          status: :fail,
          message: message
        }
      end
    end
  end
end
