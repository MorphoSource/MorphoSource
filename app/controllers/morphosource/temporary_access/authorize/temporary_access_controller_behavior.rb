module Morphosource
  module TemporaryAccess
    module Authorize
      # Customize by inheriting classes for specific kinds of temporary access links
      module TemporaryAccessControllerBehavior
        extend ActiveSupport::Concern

        # customize this
        def temporary_access_link_class
          nil
        end

        # customize this
        def accessed_document_id_field
          nil
        end

        def ability_attribute
          temporary_access_link_class.name.underscore.to_sym
        end

        private

          def authorize_with_temporary_link_if_present(id)
            if temporary_link_cookie_exists? id
              current_ability.send("#{ability_attribute}=", temporary_access_link_from_cookie(id))
            end
          end

          def temporary_link_cookie_exists?(id)
            cookies.encrypted[id].present? && 
            active_temporary_access_links.exists?(accessed_document_id_field => id, :token => cookies.encrypted[id])
          end

          def temporary_access_link_from_cookie(id)
            active_temporary_access_links.find_by(accessed_document_id_field => id, :token => cookies.encrypted[id])
          end

          def active_temporary_access_links
            temporary_access_link_class.active_links
          end
      end
    end
  end
end
