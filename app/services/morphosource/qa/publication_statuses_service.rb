# app/services/morphosource/qa/publication_statuses_service.rb
module Morphosource
  module Qa
    # Provide select options for the media types field
    class PublicationStatusesService < Morphosource::QaSelectService
      def initialize(_authority_name = nil)
        super('publication_statuses')
      end
    end
  end
end