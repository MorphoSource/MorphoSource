module BatchSubmissionTools
  module Ms2Batch
    module Models
      class MediaManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :organization_id, :media_path, :attrs
        attr_accessor :organization_permissions_fields, :organization_attachment_id

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, organization_id: nil, media_path: nil, 
            media_ownership_fields: {}, attrs: {}, **kwargs)
          
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @organization_id = organization_id
#          if organization_id.present?
#            @organization_permissions_fields = {}
#            Organization.find(organization_id).permissions_fields.map do |k,v|
#              @organization_permissions_fields[k] = v.to_a
#            end
#          end
          @media_path = media_path
          @media_ownership_fields = media_ownership_fields
          if !attrs.present? && initial_attrs.present?
#byebug
            @attrs = create_new_attributes
          else
#byebug
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
          addl_attrs.merge!(@media_ownership_fields).symbolize_keys!
          addl_attrs.merge!(visibility_mapped(@media_ownership_fields["visibility"]))

#          if organization_id.present?
#            addl_attrs.merge!(
#              organization_permissions_fields
#                .select { |k, v| Array(v)&.first.present? }
#            ) 
#            addl_attrs.merge!(visibility_from_organization)
#          end

          p = media_file_path
          addl_attrs[:file] = [p] if p.present?          
#byebug
#          tmp = initial_attrs.except(:id, :media_file).merge(addl_attrs)
#byebug
# check tmp[:file] should be set here

#          if initial_attrs[:preview_file].present? && media_path.present?
#byebug
#            preview_file = media_path + initial_attrs[:preview_file].first
#          end

          Importer::Factory::MediaFactory.new(
            initial_attrs.except(:id, :media_file).merge(addl_attrs), 
            ( File.dirname(p) if p.present? ),
            false
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

        def visibility_mapped(requested_visibility)
          public = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          private = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

          case requested_visibility
          when public
            { 
              :visibility => public,
              :fileset_visibility => "",
              :fileset_accessibility => "open"
            }
          when private
            { 
              :visibility => private,
              :fileset_visibility => "",
              :fileset_accessibility => "private"
            }
          when 'restricted_download'
            { 
              :visibility => public,
              :fileset_visibility => "",
              :fileset_accessibility => "restricted_download"
            }
          else
            {}
          end
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