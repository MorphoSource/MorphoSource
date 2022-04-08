module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base
      include BreadcrumbsForCollections
      include Morphosource::CollectionHelper
      helper_method :hidden_params_for_filters, :hidden_params_for_pagination, :publication_status_label,
        :media_type_label, :filter_params, :ms_collection_view_link, :source_label, :dashboard_bso_tab_url, :dashboard_cho_tab_url, :origin_label, :filter_projects, :ms_collection_view_link, :ms_collection_view_link_qs

      with_themed_layout 'morphosource_dashboard'
      #with_themed_layout :decide_layout

      before_action :filter_docs_with_read_access!, except: [:show, :update, :edit]
      before_action :filter_docs_with_edit_access!, only: [:update]
      before_action :remove_select_something_first_flash, except: [:show]

      include Hyrax::Collections::AcceptsBatches

      # include the render_check_all view helper method
      helper Hyrax::BatchEditsHelper
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied, with: :deny_collection_access

      # actions: index, create, new, edit, show, update, destroy, permissions, citation
      before_action :authenticate_user!, except: [:index]

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :membership_service_class,
                      :information_service_class

      #self.presenter_class = Hyrax::CollectionPresenter
      self.presenter_class = Hyrax::TeamPresenter

      self.form_class = Hyrax::Forms::CollectionForm

      # The search builder to find the collection
      self.single_item_search_builder_class = SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.membership_service_class = Morphosource::Collections::CollectionMemberService
      self.information_service_class = Morphosource::Collections::CollectionInformationService

      load_and_authorize_resource except: [:index, :specimens, :chos, :create], instance_name: :collection

      def deny_collection_access(exception)
        byebug
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

      def new
        # Coming from the UI, a collection type id should always be present.  Coming from the API, if a collection type id is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        collection_type_id = params[:collection_type_id].presence || default_collection_type.id
        @collection.collection_type_gid = CollectionType.find(collection_type_id).gid
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        byebug
        add_breadcrumb t('.header', type_title: @collection.collection_type.title), request.path
        @collection.apply_depositor_metadata(current_user.user_key)
        form
      end

      def show
        byebug
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

      def after_create
        form
        set_default_permissions
        # if we are creating the new collection as a subcollection (via the nested collections controller),
        # we pass the parent_id through a hidden field in the form and link the two after the create.
        link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end

      def after_create_error
        form
        respond_to do |format|
          format.html { render action: 'new' }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end

      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = ::Collection.new
        authorize! :create, @collection
        # Coming from the UI, a collection type gid should always be present.  Coming from the API, if a collection type gid is not specified,
        # use the default collection type (provides backward compatibility with versions < Hyrax 2.1.0)
        @collection.collection_type_gid = params[:collection_type_gid].presence || default_collection_type.gid
        @collection.attributes = collection_params.except(:members, :parent_id, :collection_type_gid)
        @collection.apply_depositor_metadata(current_user.user_key)
        add_members_to_collection unless batch.empty?
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      def after_update
        respond_to do |format|
          format.html { redirect_to update_referer, notice: t('hyrax.dashboard.my.action.collection_update_success') }
          format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
        end
      end

      def after_update_error
        form
        respond_to do |format|
          format.html { render action: 'edit' }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
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

      def after_destroy_error(id)
        respond_to do |format|
          format.html do
            flash[:notice] = t('hyrax.dashboard.my.action.collection_delete_fail')
            render :edit, status: :unprocessable_entity
          end
          format.json { render json: { id: id }, status: :unprocessable_entity, location: dashboard_collection_path(@collection) }
        end
      end

      def destroy
        if @collection.destroy
          after_destroy(params[:id])
        else
          after_destroy_error(params[:id])
        end
      end

      def collection
        action_name == 'show' ? @presenter : @collection
      end

      # Renders a JSON response with a list of files in this collection
      # This is used by the edit form to populate the thumbnail_id dropdown
      def files
        result = form.select_files.map do |label, id|
          { id: id, text: label }
        end
        render json: result
      end

      def search_builder_class
        Hyrax::Dashboard::CollectionsSearchBuilder
      end

      private

        def default_collection_type
          Hyrax::CollectionType.find_or_create_default_collection_type
        end

        def link_parent_collection(parent_id)
          parent = ActiveFedora::Base.find(parent_id)
          Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(parent: parent, child: @collection)
        end

        def uploaded_files(uploaded_file_ids)
          return [] if uploaded_file_ids.empty?
          UploadedFile.find(uploaded_file_ids)
        end

        def update_referer
          return edit_dashboard_collection_path(@collection) + (params[:referer_anchor] || '') if params[:stay_on_edit]
          dashboard_collection_path(@collection)
        end

        def process_banner_input
          return update_existing_banner if params["banner_unchanged"] == "true"
          remove_banner
          uploaded_file_ids = params["banner_files"]
          add_new_banner(uploaded_file_ids) if uploaded_file_ids
        end

        def update_existing_banner
          banner_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
          banner_info.first.save(banner_info.first.local_path, false)
        end

        def add_new_banner(uploaded_file_ids)
          f = uploaded_files(uploaded_file_ids).first
          banner_info = CollectionBrandingInfo.new(
            collection_id: @collection.id,
            filename: File.split(f.file_url).last,
            role: "banner",
            alt_txt: "",
            target_url: ""
          )
          banner_info.save f.file_url
        end

        def remove_banner
          banner_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
          banner_info&.delete_all
        end

        def update_logo_info(uploaded_file_id, alttext, linkurl)
          logo_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "logo").where(local_path: uploaded_file_id.to_s)
          logo_info.first.alt_text = alttext
          logo_info.first.target_url = linkurl
          logo_info.first.local_path = uploaded_file_id
          logo_info.first.save(uploaded_file_id, false)
        end

        def create_logo_info(uploaded_file_id, alttext, linkurl)
          file = uploaded_files(uploaded_file_id)
          logo_info = CollectionBrandingInfo.new(
            collection_id: @collection.id,
            filename: File.split(file.file_url).last,
            role: "logo",
            alt_txt: alttext,
            target_url: linkurl
          )
          logo_info.save file.file_url
          logo_info
        end

        def remove_redundant_files(public_files)
          # remove any public ones that were not included in the selection.
          logos_info = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "logo")
          logos_info.each do |logo_info|
            logo_info.delete(logo_info.local_path) unless public_files.include? logo_info.local_path
            logo_info.destroy unless public_files.include? logo_info.local_path
          end
        end

        def process_logo_records(uploaded_file_ids)
          public_files = []
          uploaded_file_ids.each_with_index do |ufi, i|
            if ufi.include?('public')
              update_logo_info(ufi, params["alttext"][i], verify_linkurl(params["linkurl"][i]))
              public_files << ufi
            else # brand new one, insert in the database
              logo_info = create_logo_info(ufi, params["alttext"][i], verify_linkurl(params["linkurl"][i]))
              public_files << logo_info.local_path
            end
          end
          public_files
        end

        def process_logo_input
          uploaded_file_ids = params["logo_files"]
          public_files = []

          if uploaded_file_ids.nil?
            remove_redundant_files public_files
            return
          end

          public_files = process_logo_records uploaded_file_ids
          remove_redundant_files public_files
        end

        # run a solr query to get the collections the user has access to edit
        # @return [Array] a list of the user's collections
        def find_collections_for_form
          Hyrax::CollectionsService.new(self).search_results(:edit)
        end

        def remove_select_something_first_flash
          flash.delete(:notice) if flash.notice == 'Select something first'
        end

        def presenter
          @presenter ||= begin
            # Query Solr for the collection.
            # run the solr query to find the collection members
            response = repository.search(single_item_search_builder.query)
            curation_concern = response.documents.first
            raise CanCan::AccessDenied unless curation_concern
            presenter_class.new(curation_concern, current_ability)
          end
        end

        # Instantiates the search builder that builds a query for a single item
        # this is useful in the show view.
        def single_item_search_builder
          single_item_search_builder_class.new(self).with(params.except(:q, :page))
        end

        def collection_params
          @participants = extract_old_style_permission_attributes(params[:collection])
          form_class.model_attributes(params[:collection])
        end

        def extract_old_style_permission_attributes(attributes)
          # TODO: REMOVE in 3.0 - part of deprecation of permission attributes
          permissions = attributes.delete("permissions_attributes")
          return [] unless permissions
          Deprecation.warn(self, "Passing in permissions_attributes parameter with a new collection is deprecated and support will be removed from Hyrax 3.0. " \
                                 "Use Hyrax::PermissionTemplate instead to grant Manage, Deposit, or View access.")
          participants = []
          permissions.each do |p|
            access = access(p)
            participants << { agent_type: agent_type(p), agent_id: p["name"], access: access } if access
          end
          participants
        end

        def agent_type(permission)
          # TODO: REMOVE in 3.0 - part of deprecation of permission attributes
          return 'group' if permission["type"] == 'group'
          'user'
        end

        def access(permission)
          # TODO: REMOVE in 3.0 - part of deprecation of permission attributes
          return Hyrax::PermissionTemplateAccess::MANAGE if permission["access"] == 'edit'
          return Hyrax::PermissionTemplateAccess::VIEW if permission["access"] == 'read'
        end

        def process_member_changes
          case params[:collection][:members]
          when 'add' then add_members_to_collection
          when 'remove' then remove_members_from_collection
          when 'move' then move_members_between_collections
          end
        end

        def add_members_to_collection(collection = nil)
          collection ||= @collection
          collection.add_member_objects batch
        end

        def remove_members_from_collection
          @collection.remove_member_objects(batch)
        end

        def move_members_between_collections
          destination_collection = ::Collection.find(params[:destination_collection_id])
          remove_members_from_collection
          add_members_to_collection(destination_collection)
          if destination_collection.save
            flash[:notice] = "Successfully moved #{batch.count} files to #{destination_collection.title} Collection."
          else
            flash[:error] = "An error occured. Files were not moved to #{destination_collection.title} Collection."
          end
        end

        # Include 'catalog' and 'hyrax/base' in the search path for views, while prefering
        # our local paths. Thus we are unable to just override `self.local_prefixes`
        def _prefixes
          @_prefixes ||= super + ['catalog', 'hyrax/base']
        end

        def ensure_admin!
          # Even though the user can view this collection, they may not be able to view
          # it on the admin page.
          authorize! :read, :admin_dashboard
        end

        def search_action_url(*args)
          hyrax.dashboard_collections_url(*args)
        end

        def form
          @form ||= form_class.new(@collection, current_ability, repository)
        end

        def set_default_permissions
          additional_grants = @participants # Grants converted from older versions (< Hyrax 2.1.0) where share was edit or read access instead of managers, depositors, and viewers
          Collections::PermissionsCreateService.create_default(collection: @collection, creating_user: current_user, grants: additional_grants)
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

        # Instantiate the membership query service
        def collection_member_service
          @collection_member_service ||= membership_service_class.new(scope: self, collection: collection, params: params_for_query)
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

        def member_subcollections
          results = collection_member_service.available_member_subcollections
          @subcollection_solr_response = results
          @subcollection_docs = results.documents
          @subcollection_count = @presenter.nil? ? 0 : @subcollection_count = @presenter.subcollection_count = results.total
        end

        def parent_collections
          page = params[:parent_collection_page].to_i
          query = Hyrax::Collections::NestedCollectionQueryService
          collection.parent_collections = query.parent_collections(child: collection_object, scope: self, page: page)
        end

        def collection_object
          action_name == 'show' ? Collection.find(collection.id) : collection
        end

        # You can override this method if you need to provide additional
        # inputs to the search builder. For example:
        #   search_field: 'all_fields'
        # @return <Hash> the inputs required for the collection member search builder
        def params_for_query
          #params.merge(q: params[:cq])

          # setting higher collection limit for paginating the array
          params.merge(q: params[:cq])
        end

        # Only accept HTTP|HTTPS urls;
        # @return <String> the url
        def verify_linkurl(linkurl)
          url = Loofah.scrub_fragment(linkurl, :prune).to_s
          url if valid_url?(url)
        end

        def valid_url?(url)
          (url =~ URI.regexp(['http', 'https']))
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
