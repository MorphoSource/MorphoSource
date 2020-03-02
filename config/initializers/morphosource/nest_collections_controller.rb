# frozen_string_literal: true

Hyrax::Dashboard::NestCollectionsController.class_eval do
  # Override to nest collections of different types

  # create and link a NEW subcollection under this collection, with this collection as parent
  def create_collection_under
    @form = build_create_collection_form
    if @form.validate_add
      redirect_to new_dashboard_collection_path(collection_type_id: selected_type_id, parent_id: @form.parent)
    else
      redirect_to redirect_path(item: @form.parent), flash: { error: @form.errors.full_messages }
    end
  end

  private

  def selected_type_id
    if params.key?(:collection_type)
      Hyrax::CollectionType.find_by(machine_id: params[:collection_type]).id
    else
      @form.parent.collection_type.id
    end
  end
end
