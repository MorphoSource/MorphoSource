module BatchSubmissionTools
  module Ms2Batch
    module Models
      # Takes initial processing event and media attrs and creates new attributes for work creation
      class MediaPeManifest
        attr_accessor :media, :pe

        def initialize(media: nil, pe: nil)
          @media = media
          @pe = pe
        end

        def to_h
          instance_values.symbolize_keys.transform_values(&:to_h)
        end
      end
    end
  end
end