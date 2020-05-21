module Hyrax
  module Dashboard
    class MsNestCollectionsController < NestCollectionsController

      # taken from the method create_collection_under
      # create and link a NEW Project under this collection (a team), with this collection as parent
      # the redirect URL's collection_type_id should be 3 (for project) when creating new collection 
      # e.g. /dashboard/collections/new?collection_type_id=3&locale=en&parent_id=<parent_id>
      def create_collection_under 
        if params["target_collection_type_id"].nil?
          target_collection_type_id = @form.parent.collection_type.id
        else
          target_collection_type_id = params["target_collection_type_id"]
        end
        @form = build_create_collection_form
        if @form.validate_add
          redirect_to new_dashboard_collection_path(collection_type_id: target_collection_type_id, parent_id: @form.parent)
        else
          redirect_to redirect_path(item: @form.parent), flash: { error: @form.errors.full_messages }
        end
      end

    end
  end
end
