module BatchSubmissionTools
  module ConvertedMs1Batch
    module Models
      class MediaManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :media_path, :attrs

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, media_path: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @media_path = media_path
          if !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def create_new_attributes
          addl_attrs = { 
            depositor: depositor, 
            on_behalf_of: on_behalf_of, 
            download_reviewer: download_reviewer,
            description: description
          }
          p = media_file_path
          addl_attrs[:file] = [p] if p.present?

          Importer::Factory::MediaFactory.new(
            initial_attrs.except(:id, :media_file).merge(addl_attrs),
            ( File.dirname(p) if p.present? )
          ).create_attributes
        end

        def download_reviewer
          on_behalf_of.present? ? [on_behalf_of] : [depositor] 
        end

        def description
          if initial_attrs[:description].present?
            initial_attrs[:description].first.to_s + "\r\n\r\n" + description_text
          else
            description_text
          end
        end

        def description_text
          'Record created by batch submission.'
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