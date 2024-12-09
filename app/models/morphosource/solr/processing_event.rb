module Morphosource
  module Solr
    module ProcessingEvent

      PROCESSING_EVENT_PROPERTIES = %w[processing_activity
                                       processing_activity_description
                                       processing_activity_software
                                       processing_activity_type
                                       description_attachment].freeze

      def processing_event?
        self['has_model_ssim'] == ['ProcessingEvent']
      end
    end
  end
end
