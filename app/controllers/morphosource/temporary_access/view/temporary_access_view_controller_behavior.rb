module Morphosource
  module TemporaryAccess
    module View
      module TemporaryAccessViewControllerBehavior
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
      end
    end
  end
end