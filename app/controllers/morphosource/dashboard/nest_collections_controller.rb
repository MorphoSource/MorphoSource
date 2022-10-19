module Morphosource
  module Dashboard
    class NestCollectionsController < Hyrax::Dashboard::NestCollectionsController

      # taken from the method create_collection_under
      # create and link a NEW Project under this collection (a team), with this collection as parent
      def create_collection_under
        @form = build_create_collection_form
        if @form.validate_add
          redirect_to new_project_path(parent_id: @form.parent)
        else
          redirect_to redirect_path(item: @form.parent), flash: { error: @form.errors.full_messages }
        end
      end

    end
  end
end
