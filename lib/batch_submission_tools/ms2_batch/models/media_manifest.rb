module BatchSubmissionTools
  module Ms2Batch
    module Models
      class MediaManifest
        attr_accessor :initial_attrs, :depositor, :owner, :on_behalf_of, :organization_id, :media_path, :attrs
        attr_accessor :id, :work, :work_imported, :derived_parent_file
        attr_accessor :organization_permissions_fields, :organization_attachment_id

        def initialize(initial_attrs: {}, depositor: nil, owner: nil, on_behalf_of: nil, organization_id: nil, media_path: nil, media_ownership_fields: {}, derived_parent_file: nil, attrs: {}, work_imported: false, **kwargs)

          @initial_attrs = initial_attrs
          @depositor = depositor
          @owner = owner
          @on_behalf_of = on_behalf_of
          @organization_id = organization_id

          @id = initial_attrs[:ms_id] || id
          @work = work
          @work_imported = work_imported

          @media_path = media_path
          @media_ownership_fields = media_ownership_fields
          @derived_parent_file = derived_parent_file
          if work.present?
            @id = work.id
            @work_imported = false
            @attrs = attrs
          elsif !attrs.present? && initial_attrs.present?
            @attrs = create_new_attributes
          else
            @attrs = attrs
          end
        end

        def work
          @work ||=
            if (
                id.present? &&
                ::Media.exists?(id)
              )
              ::Media.find(id)
            else
              nil
            end
        end

        def create_new_attributes
          addl_attrs = additional_attributes
          p = media_file_path
          files_dir = nil
          if p.present?
            addl_attrs[:file] = [p]
            if is_remote_backed?
              files_dir = :is_remote
              addl_attrs[:remote_origin_url] = [p]
            else
              files_dir = File.dirname(p)
            end
          end

          BatchSubmissionsImporter::Factory::MediaFactory.new(
            initial_attrs.except(:id, :media_file).merge(addl_attrs),
            files_dir,
            false
          ).create_attributes
        end

        def additional_attributes
          attrs = {
            depositor: depositor,
            owner: owner,
            on_behalf_of: on_behalf_of,
            download_reviewer: download_reviewer,
            description: description,
            derived_parent_file: derived_parent_file
          }
          attrs.merge!(@media_ownership_fields).symbolize_keys!
          attrs.merge!(visibility_mapped(@media_ownership_fields["visibility"]))
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

        def is_remote_backed?
          @is_remote_backed ||= initial_attrs[:media_file].first.match(/^https?:\/\//).present?
        end

        def media_file_path
          if Dir.exist?(media_path) && initial_attrs[:media_file]&.first.present?
            # todo: use another way to check if this is for remote file
            if is_remote_backed?
              return initial_attrs[:media_file].first
            else
              return File.join(media_path, initial_attrs[:media_file].first)
            end
          else
            return nil
          end
        end

        def to_h
          instance_values.symbolize_keys.except(:work)
        end
      end
    end
  end
end