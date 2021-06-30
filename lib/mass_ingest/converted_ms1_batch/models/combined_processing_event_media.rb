module MassIngest
  module ConvertedMs1Batch
    module Models
      # Takes initial processing ever and media attrs and creates new attributes for work creation
      class CombinedProcessingEventMedia
        attr_accessor :initial_pe_attrs, :initial_media_attrs, :depositor, :media_path
        attr_accessor :pe_attrs, :media_attrs

        def initialize(initial_pe_attrs, initial_media_attrs, depositor, media_path)
          @initial_pe_attrs = initial_pe_attrs
          @initial_media_attrs = initial_media_attrs
          @depositor = depositor
          @media_path = media_path

          if initial_pe_attrs.present? && initial_media_attrs.present?
            @pe_attrs = create_new_pe_attrs
            @media_attrs = create_new_media_attrs
          end
        end

        def create_new_pe_attrs
          addl_attrs = { depositor: depositor.user_key }

          Importer::Factory::ProcessingEventFactory.new(
            initial_pe_attrs.except(:id).merge(addl_attrs)
          ).create_attributes
        end

        def create_new_media_attrs
          addl_attrs = { depositor: depositor.user_key }
          addl_attrs[:file] = media_file_path if media_file_path.present?

          Importer::Factory::MediaFactory.new(
            initial_media_attrs.except(:id, :media_file).merge(addl_attrs)
          ).create_attributes
        end

        def media_file_path
          if Dir.exists?(media_path) && initial_media_attrs[:media_file]&.first.present?
            p = File.join(media_path, initial_media_attrs[:media_file]&.first) 
            if File.exists?(p)
              return file
            else
              return file #remove after initial testing
              # raise "File at path #{p} not found"
            end
          end
        end
      end
    end
  end
end