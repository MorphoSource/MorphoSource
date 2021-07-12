module MassIngest
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
          addl_attrs = { depositor: depositor.user_key }
          addl_attrs[:file] = media_file_path if media_file_path.present?

          Importer::Factory::MediaFactory.new(
            initial_attrs.except(:id, :media_file).merge(addl_attrs)
          ).create_attributes
        end

        def media_file_path
          if Dir.exists?(media_path) && initial_attrs[:media_file]&.first.present?
            p = File.join(media_path, initial_attrs[:media_file]&.first) 
            if File.exists?(p)
              return file
            else
              return file #remove after initial testing
              # raise "File at path #{p} not found"
            end
          end
        end

        def to_h
          instance_values.transform_keys(&:to_sym)
        end
      end
    end
  end
end