# frozen_string_literal: true

Hyrax::Dashboard::CollectionsController.class_eval do
  helper Morphosource::CollectionRolesHelper

  def after_create
    # TODO: Experiencing occasional bug where this code is not called when expected. Puts statements below to assist in debugging
    puts 'Custom CollectionsController after_create called'
    puts "@collection.type_assigns_groups?:   #{@collection.type_assigns_groups?}"
    form
    choose_permissions
    # if we are creating the new collection as a subcollection (via the nested collections controller),
    # we pass the parent_id through a hidden field in the form and link the two after the create.
    link_parent_collection(params[:parent_id]) unless params[:parent_id].nil?
    respond_to do |format|
      ActiveFedora::SolrService.commit
      format.html { redirect_to edit_dashboard_collection_path(@collection), notice: t('hyrax.dashboard.my.action.collection_create_success') }
      format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
    end
  end

  def choose_permissions
    if @collection.type_assigns_groups?
      set_morphosource_permissions
    else
      set_default_permissions
    end
  end

  def set_morphosource_permissions
    # TODO: Experiencing occasional bug where this code is not called when expected. Puts statements below to assist in debugging
    puts 'set_morphosource_permissions called'
    @collection.create_collection_groups
    @collection.copy_parent_membership(params[:parent_id]) unless params[:parent_id].nil?
    Hyrax::Collections::PermissionsCreateService.create_ms_template(collection: @collection)
  end
end
