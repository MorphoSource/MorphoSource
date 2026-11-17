module Morphosource
  module Api
    # Contents of the API key owner's Media Cart.
    #
    #   GET /api/media-cart
    #
    # Optional params:
    #   access   - 'downloadable' or 'restricted' to filter items by download access
    #   page     - page number (default 1)
    #   per_page - items per page (default DEFAULT_PER_PAGE, max MAX_PER_PAGE)
    #
    # Cart membership and access rules come from the same User/CartItem methods
    # that back the dashboard Media Cart (Morphosource::My::MediaCartsController).
    class MediaCartController < BaseController
      ACCESS_FILTERS = %w[downloadable restricted].freeze

      before_action :validate_params

      def index
        # most recently added first
        items = filtered_items.sort_by { |item| [item.created_at, item.id] }.reverse
        paginated = paginate_array(items)

        render json: {
          response: {
            media_cart: paginated.map { |item| item_json(item) },
            pages: pagination_info(paginated)
          }
        }
      end

      private

        def validate_params
          errors = pagination_param_errors
          if params[:access].present? && !ACCESS_FILTERS.include?(params[:access])
            errors << "access must be one of: #{ACCESS_FILTERS.join(', ')}"
          end
          render_json_by_http_code(400, errors) if errors.present?
        end

        # Unfiltered requests only evaluate access for the paged items (in
        # #item_json). Filtered requests must evaluate every item in the cart,
        # so results are cached for reuse in #item_json.
        def filtered_items
          items = current_user.items_in_cart
          case params[:access]
          when 'downloadable' then items.select { |item| downloadable?(item) }
          when 'restricted'   then items.reject { |item| downloadable?(item) }
          else items
          end
        end

        # CartItem#downloadable? is expensive (Solr, User and ability lookups);
        # compute it at most once per item per request.
        def downloadable?(item)
          @downloadable ||= {}
          return @downloadable[item.id] if @downloadable.key?(item.id)
          @downloadable[item.id] = item.downloadable?
        end

        def item_json(item)
          doc = item.work
          downloadable = downloadable?(item)
          {
            id: item.id,
            media_id: item.work_id,
            media_title: doc&.title_or_label,
            media_url: doc.present? ? main_app.hyrax_media_url(item.work_id) : nil,
            media_api_url: doc.present? ? main_app.api_media_show_url(item.work_id) : nil,
            media_available: doc.present?,
            physical_object: physical_object_json(doc),
            downloadable: downloadable,
            restricted: !downloadable,
            request_status: item.request_status,
            date_added: format_date(item.created_at),
            date_requested: format_date(item.date_requested),
            date_approved: format_date(item.date_approved),
            date_expired: format_date(item.date_expired),
            date_downloaded: format_date(item.date_downloaded)
          }
        end

        def physical_object_json(doc)
          return nil unless doc.present? && doc['physical_object_id_ssim'].present?
          {
            id: doc['physical_object_id_ssim']&.first,
            title: doc['physical_object_title_ssim']&.first,
            type: doc['media_physical_object_type_ssim']&.first,
            taxonomy: doc['taxonomy_tesim']&.first
          }
        end

        def format_date(value)
          value&.iso8601
        end
    end
  end
end
