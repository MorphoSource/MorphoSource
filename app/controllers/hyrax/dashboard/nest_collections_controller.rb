module Hyrax
  module Dashboard
    class NestCollectionsController < ApplicationController
      include Blacklight::Base
      class_attribute :form_class, :new_collection_form_class
      self.form_class = Hyrax::Forms::Dashboard::NestCollectionForm
      self.new_collection_form_class = Hyrax::Forms::CollectionForm

      before_action :get_parent_and_child, only: [:create_relationship_under, :remove_relationship_under]

      # Add this collection as a subcollection within another existing collection
      def create_relationship_within
        @form = build_within_form
        if @form.save
          notice = I18n.t('create_within', scope: 'hyrax.dashboard.nest_collections_form', child_title: @form.child.title.first, parent_title: @form.parent.title.first)
          redirect_to redirect_path(item: @form.child), notice: notice
        else
          redirect_to redirect_path(item: @form.child), flash: { error: @form.errors.full_messages }
        end
      end

      # create and link a NEW subcollection under this collection, with this collection as parent
      def create_collection_under
        @form = build_create_collection_form
        if @form.validate_add
          redirect_to new_dashboard_collection_path(collection_type_id: @form.parent.collection_type.id, parent_id: form.parent)
        else
          redirect_to redirect_path(item: @form.parent), flash: { error: @form.errors.full_messages }
        end
      end

      # link this collection as parent by adding existing collection as subcollection under this one
      def create_relationship_under
        # user must be able to edit both parent and child
        authorize_parent_and_child
        # nest the child in the parent
        if Hyrax::Collections::NestedCollectionPersistenceService.persist_nested_collection_for(parent: @parent, child: @child)
          # copy parent membership to child
          @child.copy_parent_membership(@parent.id)
          # construct notice
          notice = I18n.t('create_under', scope: 'hyrax.dashboard.nest_collections_form', child_title: @child.title.first, parent_title: @parent.title.first)
          # redirect to projects tab
          respond_to do |format|
            format.js {render :js => "location.reload()"}
            format.html do
              redirect_to(main_app.team_projects_path(@parent.id), notice: notice)
            end
          end
        else
          alert = "There was an error. #{@child.title.first} was not added to #{@parent.title.first}"
          respond_to do |format|
            format.js {render :js => "location.reload();alert('There was an error removing collection.')"}
            format.html do
              redirect_to(main_app.team_projects_path_path(@parent.id), alert: alert)
            end
          end
        end
      end

      # remove a parent collection relationship from this collection
      def remove_relationship_above
        @form = build_remove_form
        if @form.remove
          notice = I18n.t('removed_relationship', scope: 'hyrax.dashboard.nest_collections_form', child_title: @form.child.title.first, parent_title: @form.parent.title.first)
          redirect_to redirect_path(item: @form.child), notice: notice
        else
          redirect_to redirect_path(item: @form.child), flash: { error: @form.errors.full_messages }
        end
      end

      # remove a subcollection relationship from this collection
      def remove_relationship_under
        @form = build_remove_form
        if @form.remove
          @child.remove_parent_membership(@parent, current_user)
          notice = I18n.t('removed_relationship', scope: 'hyrax.dashboard.nest_collections_form', child_title: @form.child.title.first, parent_title: @form.parent.title.first)
          respond_to do |format|
            format.js {render :js => "location.reload()"}
            format.html do
              redirect_to(main_app.team_projects_path(@parent), notice: notice)
            end
          end
        else
          respond_to do |format|
            format.js {render :js => "location.reload();alert('There was an error removing collection.')"}
            format.html do
              redirect_to redirect_path(item: @form.parent), flash: { error: @form.errors.full_messages }
            end
          end
        end
      end

      private

        def build_within_form
          child = Collection.find(params.fetch(:child_id))
          authorize! :read, child
          parent = params.key?(:parent_id) ? Collection.find(params[:parent_id]) : nil
          form_class.new(child: child, parent: parent, context: self)
        end

        def build_under_form
          parent = Collection.find(params.fetch(:parent_id))
          authorize! :deposit, parent
          child = params.key?(:child_id) ? Collection.find(params[:child_id]) : nil
          form_class.new(child: child, parent: parent, context: self)
        end

        def build_create_collection_form
          parent = Collection.find(params.fetch(:parent_id))
          authorize! :deposit, parent
          form_class.new(child: nil, parent: parent, context: self)
        end

        def build_remove_form
          authorize! :edit, @parent
          form_class.new(child: @child, parent: @parent, context: self)
        end

        # determine appropriate redirect location depending on specified source
        def redirect_path(item:)
          return my_collections_path if params[:source] == 'my'
          dashboard_collection_path(item)
        end

        def get_parent_and_child
          @child = Collection.find(params["child_id"])
          @parent = Collection.find(params["parent_id"])
        end

        def authorize_parent_and_child
          (authorize! :edit, @parent) && (authorize! :edit, @child)
        end
    end
  end
end
