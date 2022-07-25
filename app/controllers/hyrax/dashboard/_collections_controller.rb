module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController

      include Morphosource::CollectionHelper

      with_themed_layout 'morphosource_dashboard'

      before_action :filter_docs_with_edit_access!, only: [:update]

      helper_method :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
        :media_type_label, :filter_params, :ms_collection_view_link, :source_label, :dashboard_bso_tab_url, :dashboard_cho_tab_url, :origin_label, :filter_projects, :ms_collection_view_link, :ms_collection_view_link_qs


      class_attribute :information_service_class

      self.presenter_class = Hyrax::TeamPresenter

      self.form_class = Hyrax::Forms::CollectionForm

      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService

      self.information_service_class = Morphosource::Collections::CollectionInformationService

      def deny_collection_access(exception)
        if exception.action == :edit
          #redirect_to(url_for(action: 'show'), alert: 'You do not have sufficient privileges to edit this document')
          redirect_to root_url, alert: 'You do not have sufficient privileges to edit this collection'
          # todo: might be better to redirect to /dashboard/collections
        elsif current_user&.persisted?
          redirect_to root_url, alert: exception.message
        else
          session['user_return_to'] = request.url
          redirect_to main_app.new_user_session_url, alert: exception.message
        end
      end


      def show
        # if the current user has edit permission, redirect to edit
        if current_user and can? :edit, @collection
          tab = request.params[:tab]
          edit_path = edit_dashboard_collection_url + '&' + request.params.slice!(:action, :id, :controller, :locale, :tab).to_query
          edit_path += '#' + tab if tab.present?
          redirect_to edit_path
        elsif current_user and can? :read, @collection
          # if the user only has read access, redirect to the public view page
          if collection.project?
            redirect_to main_app.project_media_path
          elsif collection.team?
            redirect_to main_app.team_media_path
          else
            redirect_to root_url
          end
        else
          # run the presenter and other methods (same as the team_presenter methods) necessary for
          # displaying teams and project show page content
          presenter
          query_collection_information
          query_collection_members
          form
        end
      end

      def edit
        byebug
        # this is called when user save the collection form on the show action
        # if needed, redirect show to edit if user has permission to save
        presenter
        query_collection_information
        query_collection_members
        form
      end

      def specimens
        presenter
        @collection ||= presenter.collection
        query_collection_information
        query_collection_members_for_po
        render partial: "hyrax/teams/tab_bso"
      end

      def chos
        presenter
        @collection ||= presenter.collection
        query_collection_information
        query_collection_members_for_po
        render partial: "hyrax/teams/tab_cho"
      end

      # todo: need to add logic to keep the old hyrax view if still needed
      def show_hyrax
        if request.parameters['hyrax'].present?
          # todo: keep the old show page in case needed.  this param check can be removed later
          if @collection.collection_type.brandable?
            banner_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
            @banner_file = "/" + banner_info.first.local_path.split("/")[-4..-1].join("/") unless banner_info.empty?
          end
          self.presenter_class = Hyrax::CollectionPresenter
          presenter
          query_collection_members
        else
          # redirect dashboard page to edit page when ready
          redirect_to '/dashboard/collections/' + @collection.id + '/edit'
        end
      end


      def update
        unless params[:update_collection].nil?
          process_banner_input
          process_logo_input
        end
        update_thumbnail
        process_member_changes
        update_physical_object_index
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        # we don't have to reindex the full graph when updating collection
        @collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        if @collection.update(collection_params.except(:members))
          after_update
        else
          after_update_error
        end
      end

      def after_destroy(_id)
        # leaving id to avoid changing the method's parameters prior to release
        respond_to do |format|
          format.js {render :js => "location.reload()"}
          format.html do
            redirect_to request.referrer
          end
          format.json { head :no_content, location: '/dashboard/my/collections' }
        end
      end

      private

        def update_referer
          return collection_media_path(@collection) if params[:showcase]

          return edit_dashboard_collection_path(@collection) + (params[:referer_anchor] || '') if params[:stay_on_edit]

          dashboard_collection_path(@collection)
        end

        def remove_members_from_collection
          @collection.remove_member_objects(batch)
        end


        def query_collection_members
          member_works # 15.7, 9.5, 53.0, 97.2 ms
          member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
          # parent collection should not be needed.  remove below later
          #parent_collections if collection.collection_type.nestable? && action_name == 'show' # 7 - 14 ms for project
          prepare_docs_and_filters_for_media(@collection)
        end

        def query_collection_members_for_po
          member_works_objects
          member_subcollections if collection.collection_type.nestable? # 7 - 21 ms
          prepare_docs_and_filters_for_po(@collection)
        end

        # Instantiate the information query service
        def collection_information_service
          @collection_information_service ||= information_service_class.new(scope: self, collection_id: collection.id)
        end

        def subcollection_media_service(subcollection)
          membership_service_class.new(scope: self, collection: subcollection, params: params_for_query)
        end

        def member_works
          @response = collection_member_service.all_member_media(
            @collection_organization_object_ids, media_filter_params)
          @member_docs = @response.documents
          @members_count = @response.total
        end

        def member_works_objects
          all_object_ids = @collection_object_ids + @collection_organization_object_ids

          if all_object_ids.present?
            @bso_response = collection_member_service.all_member_media_objects(all_object_ids, BiologicalSpecimen, bso_filter_params)
            @bso_member_docs = @bso_response.documents
            @bso_member_count = @bso_response.total

            @cho_response = collection_member_service.all_member_media_objects(all_object_ids, CulturalHeritageObject, cho_filter_params)
            @cho_member_docs = @cho_response.documents
            @cho_member_count = @cho_response.total

            if !@bso_member_count.present? && @cho_member_count.present?
              @response = @cho_response
            else
              @response = @bso_response
            end
          else
            @bso_response = nil
            @bso_member_docs = []
            @bso_member_count = 0
            @cho_response = nil
            @cho_member_docs = []
            @cho_member_count = 0
            @response = nil
          end
        end

        # media pagination methods
        def paginated_media_item_list
          # Uses kaminari to paginate an array to avoid need for solr documents for items here
          #Kaminari.paginate_array(@media_member_docs, total_count: @media_member_docs.size).page(media_current_page).per(rows_from_params)
          Kaminari.paginate_array(@member_docs, total_count: @members_count).page(media_current_page).per(rows_from_params)
        end

        def media_total_items
          @members_count
        end

        def media_current_page
          page = request.params[:page].nil? ? 1 : request.params[:page].to_i
          page > media_total_pages ? media_total_pages : page
        end

        # @return [Integer] total number of pages of viewable items
        def media_total_pages
          (media_total_items.to_f / rows_from_params.to_f).ceil
        end

        def rows_from_params
          request.params[:rows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:rows].to_i
        end

        # bso pagination methods
        def paginated_bso_item_list
          Kaminari.paginate_array(@bso_member_docs, total_count: @bso_member_count).page(bso_current_page).per(bso_rows_from_params)
        end

        def bso_total_items
          @bso_member_count
        end

        def bso_current_page
          page = request.params[:page].nil? ? 1 : request.params[:page].to_i
          page > bso_total_pages ? bso_total_pages : page
        end

        def bso_total_pages
          (bso_total_items.to_f / bso_rows_from_params.to_f).ceil
        end

        def bso_rows_from_params
          request.params[:brows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:brows].to_i
        end

        # cho pagination methods
        def paginated_cho_item_list
          Kaminari.paginate_array(@cho_member_docs, total_count: @cho_member_count).page(cho_current_page).per(cho_rows_from_params)
        end

        def cho_total_items
          @cho_member_count
        end

        def cho_current_page
          page = request.params[:page].nil? ? 1 : request.params[:page].to_i
          page > cho_total_pages ? cho_total_pages : page
        end

        def cho_total_pages
          (cho_total_items.to_f / cho_rows_from_params.to_f).ceil
        end

        def cho_rows_from_params
          request.params[:crows].nil? ? Hyrax.config.teams_show_work_item_rows : request.params[:crows].to_i
        end

        def dedup(docs)
          unique_docs = []
          unique_ids = []
          docs.each do |doc|
            unless unique_ids.include? doc.id
              unique_ids << doc.id
              unique_docs << doc
            end
          end
          return unique_docs
        end
        
        def update_thumbnail
          media = Media.where(id: params[:collection][:representative_id]).first
          @collection.thumbnail_id = media.try(:thumbnail_id)
        end

        def update_physical_object_index
          return if params["batch_document_ids"].blank?

          member_ids = params["batch_document_ids"]
          member_ids.each do |id|
            member = Media.find(id)
            object_id = member.physical_object_id
            next if object_id.blank?

            ActiveFedora::Base.where(id: object_id).first.try(:update_index)
          end
        end


        # todo: delete later since we should be able to use morphosource_dashboard for all dashboard layout
        #def decide_layout
        #  layout = case action_name
        #           when 'edit'
        #             if collection.team?
        #               'morphosource_dashboard'
        #             else
        #               'dashboard'
        #             end
        #           else
        #             'dashboard'
        #           end
        #  File.join(theme, layout)
        #end

    end
  end
end
