module MassIngest
  module ConvertedMs1Batch
    module Models
      class MediaIePeManifest
        attr_accessor :imaging_event, :parent, :children

        def initialize(imaging_event: {}, parent: {}, children: {})
          @imaging_event = imaging_event
          @parent = parent
          @children = children
        end

        def to_h
          {
            imaging_event: imaging_event.transform_keys(&:to_s).transform_values(&:to_h),
            parent: parent.transform_keys(&:to_s).transform_values(&:to_h),
            children: children.transform_keys(&:to_s).transform_values(&:to_h),
          }
        end
      end
    end
  end
end