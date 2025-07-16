module BatchSubmissionTools
  module ConvertedMs1Batch
    module Models
      class MediaManifest
        attr_accessor :initial_attrs, :depositor, :on_behalf_of, :organization_id, :media_path, :attrs
        attr_accessor :organization_permissions_fields, :organization_attachment_id

        def initialize(initial_attrs: {}, depositor: nil, on_behalf_of: nil, organization_id: nil, media_path: nil, attrs: {}, **kwargs)
          @initial_attrs = initial_attrs
          @depositor = depositor
          @on_behalf_of = on_behalf_of
          @organization_id = organization_id
          @organization_permissions_fields = 
            Organization.find(organization_id).enforced_permissions_fields if organization_id.present?
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
          if organization_id.present?
            addl_attrs.merge!(
              organization_permissions_fields
                .except(
                  :license_blank, 
                  :rights_holder_blank, 
                  :rights_statement_blank, 
                  :download_permission, 
                  :attachment_url, 
                  :organization_for_attachment
                )
            ) 
            addl_attrs.merge!(visibility_from_organization)
          end
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

        def visibility_from_organization
          if organization_id.present? and organization_permissions_fields[:download_permission]&.first.present?
            public = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
            private = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE

            case organization_permissions_fields[:download_permission]&.first
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
          else
            {}
          end
        end

        def media_file_path
          if Dir.exist?(media_path) && initial_attrs[:media_file]&.first.present?
            p = File.join(media_path, initial_attrs[:media_file]&.first) 
            if File.exist?(p)
              return p
            else
              raise "File to be submitted at path #{p} not found"
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