module Morphosource
  module API
    # Base class for REST API endpoints that are not backed by a Blacklight
    # catalog controller. Most /api routes are served by catalog controllers
    # (MediaCatalogController, ObjectsCatalogController, etc.); custom JSON
    # endpoints should subclass this instead.
    #
    # Each subclass declares its authentication with api_auth (see
    # Morphosource::RestApiBehavior), e.g.
    #   api_auth :required, scope: 'api:read'
    # and must be listed in spec/controllers/api_scopes_spec.rb.
    class BaseController < ApplicationController
      include Morphosource::RestApiBehavior

      DEFAULT_PER_PAGE = 10
      MAX_PER_PAGE = 1000

      private

        # Validation errors for the page/per_page params, for use in a
        # subclass's param validation.
        def pagination_param_errors
          errors = []
          errors << "page must be a positive integer" if params[:page].present? && !positive_integer?(params[:page])
          errors << "per_page must be a positive integer" if params[:per_page].present? && !positive_integer?(params[:per_page])
          errors
        end

        def positive_integer?(value)
          value.to_s.match?(/\A[1-9]\d*\z/)
        end

        def page_param
          params[:page].present? ? params[:page].to_i : 1
        end

        def per_page_param
          return self.class::DEFAULT_PER_PAGE unless params[:per_page].present?
          [params[:per_page].to_i, self.class::MAX_PER_PAGE].min
        end

        def paginate_array(items)
          Kaminari.paginate_array(items).page(page_param).per(per_page_param)
        end

        # Mirrors Blacklight::JsonPresenter#pagination_info so that paginated
        # responses match the catalog-backed API endpoints.
        def pagination_info(paginated)
          {
            current_page: paginated.current_page,
            next_page: paginated.next_page,
            prev_page: paginated.prev_page,
            total_pages: paginated.total_pages,
            limit_value: paginated.limit_value,
            offset_value: paginated.offset_value,
            total_count: paginated.total_count,
            first_page?: paginated.first_page?,
            last_page?: paginated.last_page?
          }
        end
    end
  end
end
