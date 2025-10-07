module Morphosource
  module Admin
    module Appearance
      class HomepageController < Morphosource::Admin::AppearanceController

        def update
          params[:admin_homepage][:featured_collections] = concat_collections
          form_class.new(update_params).update!
          redirect_to({ action: :show }, notice: update_notice)
        end

        private

        def update_params
          params.require(:admin_homepage).permit(form_params)
        end

        def form_class
          Morphosource::Forms::Admin::Homepage
        end

        def add_breadcrumbs
          super
          add_breadcrumb "Homepage", request.path
        end

        def concat_collections
          collections = form_class::SORTED_COLLECTIONS
          collections.each_with_object([]) do |col, result|
            result << params[:admin_homepage].delete(col)
          end.compact_blank.join(",")
        end
      end
    end
  end
end