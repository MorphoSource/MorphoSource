# frozen_string_literal: true
module Morphosource
  module Transactions
    # Compared to Hyrax 5.0.5 version, reaches into form resource for date uploaded if necessary
    module Steps
      # @since 3.0.0
      class SetUploadedDateUnlessPresent < Hyrax::Transactions::Steps::SetUploadedDateUnlessPresent
        ##
        # @note the implementation sets the uploaded date to
        #   `#date_modified` if it exists, falling back on the current datetime.
        #
        # @param [#date_uploaded=] obj
        #
        # @return [Dry::Monads::Result]
        def call(obj)
          return Failure[:no_date_uploaded_attribute, obj] unless
            obj.respond_to?(:date_uploaded=)

          obj.date_uploaded = date_uploaded(obj) if obj.date_uploaded.blank?

          Success(obj)
        end

        private

        def date_uploaded(obj)
          obj.try(:resource).try(:date_uploaded).presence || obj.try(:date_modified).presence || @time_service.time_in_utc
        end
      end
    end
  end
end
