module BatchSubmission
  module ConvertedMs1Batch
    module Models
      class MediaManifest
        attr_accessor :initial_attrs, :depositor, :media_path, :attrs

        def initialize(initial_attrs: {}, depositor: nil, media_path: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @media_path = media_path
          if !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def create_new_attributes
          addl_attrs = { depositor: depositor }
          p = media_file_path
          addl_attrs[:file] = [p] if p.present?

          Importer::Factory::MediaFactory.new(
            initial_attrs.except(:id, :media_file).merge(addl_attrs),
            ( File.dirname(p) if p.present? )
          ).create_attributes
        end

        def media_file_path
          if Dir.exists?(media_path) && initial_attrs[:media_file]&.first.present?
            p = File.join(media_path, initial_attrs[:media_file]&.first) 
            if File.exists?(p)
              return p
            else
              return p #remove after initial testing
              # raise "File at path #{p} not found"
            end
          end
        end

        def to_h
          instance_values.symbolize_keys
        end
      end
    end
  end
end