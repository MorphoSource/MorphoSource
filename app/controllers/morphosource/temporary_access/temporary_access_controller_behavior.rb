module Morphosource
  module TemporaryAccess
    # Customize by inheriting classes for specific kinds of temporary access links
    module TemporaryAccessControllerBehavior
      extend ActiveSupport::Concern

      included do
        class_attribute :temporary_access_link_class
      end

      # customize this
      def temporary_access_link_class
        @temporary_access_link_class ||= self.temporary_access_link_class
      end

      # customize this
      def document_id_attribute
        temporary_access_link_class.document_id_attribute
      end

      def ability_attribute
        temporary_access_link_class.name.underscore.to_sym
      end

      # Media authorization controller flow
      def authorize_media_with_temporary_link(id = nil)
        id = params[:id] if (id.nil? && params[:id].present?)

        success = false
        if params[:token].present? && controller_name == 'media'
          # user accessing project via temporary link URL, auth and set cookie if needed
          load_and_authorize_with_token
          success = true
        elsif !current_ability.can?(:read, id) && temporary_link_cookie_exists?(id)
          # user has pre-existing cookie and can't otherwise access project
          success = true if authorize_with_temporary_link_if_present(id)
        elsif !current_ability.can?(:read, id) && any_temporary_link_cookie_exists?
          # check if an appropriate project temporary link cookie exists
          if !@curation_concern.present? && Media.exists?(id)
            @curation_concern = Media.find(id)
          end
          success = authorize_media_with_collection_temporary_link_if_present(
            (@curation_concern&.member_of_collection_ids || [])
          )
        end

        if success
          flash.now[:notice] = I18n.t 'morphosource.media.view.temporary_access'
        end
      end

      # Collection authorization controller flow
      def authorize_collection_with_temporary_link
        # Use class-level attribute to determine which collections can authorize
        return unless self.can_authorize_with_temporary_link

        success = false
        if params[:token].present?
          # user accessing project via temporary link URL, auth and set cookie if needed
          load_and_authorize_with_token
          success = true
        elsif (
          params[:id].present? && 
          temporary_link_cookie_exists?(params[:id]) && 
          !current_ability.can?(:read, params[:id])
        )
          # user has pre-existing cookie and can't otherwise access project
          success = true if authorize_with_temporary_link_if_present(params[:id])
        end

        if success
          # allow user to view collection media as viewer
          load_collection
          if @collection.viewers_group
            current_ability.user_groups_append(@collection.viewers_group.name)
          end
        
          flash.now[:notice] = I18n.t(
            'morphosource.collections.view.temporary_access', 
            collection_type: 'project'
          )
        end
      end

      def any_temporary_link_cookie_exists?
        cookies.any? { |key, value| key.include?('ta_') }
      end

      private

        # Methods that validate and set temporary access based on URL params

        def load_and_authorize_with_token
          load_temporary_access_link
          authorize_temporary_access_link
          load_curation_concern
          authorize_curation_concern
          set_authorization_cookie
        end

        def load_temporary_access_link
          params.require(:id)
          params.require(:token)
          @temporary_access_link = temporary_access_link_class.find_by(document_id_attribute => params[:id], :token => params[:token])
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
          return if cookies.encrypted[cookie_name(@concern_solr_doc.id)].present?

          cookies.encrypted[cookie_name(@concern_solr_doc.id)] = { 
            value: @temporary_access_link.token, 
            expires: @temporary_access_link.expires_at
          }
        end

        # Methods specific to media authorization with cookie credentials

        def authorize_media_with_collection_temporary_link_if_present(collection_ids)
          # Change temp access link class just for this method
          original_temporary_access_link_class = temporary_access_link_class
          @temporary_access_link_class = TemporaryCollectionAccessLink

          begin
            # Authorize with project if possible
            ( 
              ( collection_id = collection_ids.find { |id| temporary_link_cookie_exists?(id) } ) &&
              authorize_with_temporary_link_if_present(collection_id) &&
              Collection.exists?(collection_id) &&
              ( @collection = Collection.find(collection_id) ) &&
              @collection&.viewers_group &&
              current_ability.user_groups_append(@collection.viewers_group.name)
            )
          ensure
            # Return temp access link class back to normal
            @temporary_access_link_class = original_temporary_access_link_class
          end
        end

        # Methods that read or make use of temporary access cookie credentials

        def authorize_with_temporary_link_if_present(id)
          if temporary_link_cookie_exists? id
            current_ability.send("#{ability_attribute}=", temporary_access_link_from_cookie(id))
          end
        end

        def temporary_link_cookie_exists?(id)
          cookies.encrypted[cookie_name(id)].present? && 
          active_temporary_access_links.exists?(
            document_id_attribute => id, 
            :token => cookies.encrypted[cookie_name(id)]
          )
        end

        def temporary_access_link_from_cookie(id)
          active_temporary_access_links.find_by(
            document_id_attribute => id, 
            :token => cookies.encrypted[cookie_name(id)]
          )
        end

        def active_temporary_access_links
          temporary_access_link_class.active_links
        end

        # General utility methods

        def cookie_name(id)
          "ta_#{id}"
        end
    end
  end
end