module Morphosource
  module Dashboard
    class NestCollectionsController < Hyrax::Dashboard::NestCollectionsController
      before_action :redirect_to_collection_type, only: []
      before_action :get_parent_and_child, only: [:create_relationship_under, :remove_relationship_under]


      # taken from the method create_collection_under
      # create and link a NEW Project under this collection (a team or organization), with this collection as parent
      def create_collection_under
        authorize! :edit, form_params[:parent_id]

        if form.validate_add
          redirect_to new_project_path(parent_id: form.parent)
        else
          redirect_to redirect_path(item: form.parent), flash: { error: form.errors.full_messages }
        end
      end

      # WARNING: Method currently unused, but could be used in future (TODO?)
      # link this collection as parent by adding existing collection as subcollection under this one
      def create_relationship_under
        # user must be able to edit both parent and child
        authorize! :edit, form_params[:parent_id]
        authorize! :edit, form_params[:child_id]

        # nest the child in the parent
        # if Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(parent: @parent, child: @child)
        if form.save
          # copy parent membership to child
          @child.copy_parent_membership(@parent.id)
          # construct notice
          notice = I18n.t('create_under', scope: 'hyrax.dashboard.nest_collections_form', child_title: form.child.title.first, parent_title: form.parent.title.first)
          # redirect to projects tab
          respond_to do |format|
            format.js {render :js => "location.reload()"}
            format.html do
              redirect_to(main_app.send("#{@parent.collection_type.machine_id}_projects_path", @parent), notice: notice)
            end
          end
        else
          alert = "There was an error. #{@child.title.first} was not added to #{@parent.title.first}"
          respond_to do |format|
            format.js {render :js => "location.reload();alert('There was an error removing collection.')"}
            format.html do
              redirect_to(main_app.send("#{@parent.collection_type.machine_id}_projects_path", @parent), alert: alert)
            end
          end
        end
      end

      # WARNING: Method currently unused, but could be used in future (TODO?)
      # remove a subcollection relationship from this collection
      def remove_relationship_under
        # user must be able to edit both parent and child
        authorize! :edit, form_params[:parent_id]
        authorize! :edit, form_params[:child_id]
        path = main_app.send("#{@parent.collection_type.machine_id}_projects_path", @parent)
        if form.remove
          @child.remove_parent_membership(@parent, current_user)
          notice = I18n.t('removed_relationship', scope: 'hyrax.dashboard.nest_collections_form', child_title: form.child.title.first, parent_title: form.parent.title.first)
          respond_to do |format|
            format.js { render js: "window.location = '#{path}&notice=#{CGI.escape(notice)}'" }
            format.html do
              redirect_to(main_app.send("#{@parent.collection_type.machine_id}_projects_path", @parent), notice: notice)
            end
          end
        else
          respond_to do |format|
            format.js {render :js => "location.reload();alert('There was an error removing collection.')"}
            format.html do
              redirect_to redirect_path(item: form.parent), flash: { error: form.errors.full_messages }
            end
          end
        end
      end

      private

      def get_parent_and_child
        @child = Collection.find(params["child_id"])
        @parent = Collection.find(params["parent_id"])
      end
    end
  end
end
