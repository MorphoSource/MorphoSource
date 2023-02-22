module Morphosource
  module TemporaryAccess
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

        # Methods that validate and set temporary access based on URL params

        def load_temporary_access_link
          params.require(:id)
          params.require(:token)
          @temporary_access_link = temporary_access_link_class.find_by(accessed_document_id_field => params[:id], :token => params[:token])
        end

        def authorize_temporary_access_link
          raise CanCan::AccessDenied.new(nil, :show) unless (@temporary_access_link.present? && @temporary_access_link.active?)
        end

        def load_curation_concern
          @concern_solr_doc = SolrDocument.find(params[:id])
        end

        def authorize_curation_concern
          current_ability.send("#{ability_attribute}=", @temporary_access_link)
          current_ability.authorize! :read, @concern_solr_doc
        end

        def set_authorization_cookie
          return if cookies.encrypted[@concern_solr_doc.id].present?

          cookies.encrypted[@concern_solr_doc.id] = { 
            value: @temporary_access_link.token, 
            expires: @temporary_access_link.expires_at
          }
        end

        # Methods that read or make use of temporary access cookie credentials

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