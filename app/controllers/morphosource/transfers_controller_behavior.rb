# Shared ItemTable wiring for the three ownership-transfer dashboards (My Transfers Received,
# My Transfers Sent, Admin All Transfers). Provides: a default "pending" status quick-filter so
# unresolved requests aren't buried among old ones, an @has_organization_transfers flag used to
# conditionally render the organization-transfer quick-filter toggle, and shared batch-decision
# helpers that hand work off to TransferDecisionJob instead of processing inline.
module Morphosource
  module TransfersControllerBehavior
    extend ActiveSupport::Concern

    included do
      prepend_before_action :default_transfer_status_filter, only: [:index]
      before_action :set_has_organization_transfers, only: [:index]
      helper_method :current_filter_items, :quick_filter_status_url, :quick_filter_all_statuses_url,
                    :quick_filter_organization_transfer_url, :current_transfer_status
    end

    # Override in the including controller: the unfiltered, unpaginated base scope.
    def base_transfer_scope
      raise NotImplementedError, "#{self.class} must implement #base_transfer_scope"
    end

    # "Transfer" reads far better than ProxyDepositRequest's default humanized model name
    # ("proxy deposit request") in pagination text like "No transfers found".
    def entry_name
      'transfer'
    end

    # The status quick-filter currently in effect, or 'all'. Shared by _quick_filters (to highlight
    # the active option) and #empty_state_message (to name it in the empty-state message) so the
    # two can't drift out of sync.
    def current_transfer_status
      params[:all_statuses] == 'true' ? 'all' : (params.dig(:filter_items, 'status') || 'pending')
    end

    # These pages default to a "pending" status filter (see #default_transfer_status_filter) so
    # unresolved requests aren't buried among old ones -- but that means the page looks empty the
    # moment a user has decided everything. Rather than silently switching the default filter (which
    # would make the page behave differently with no visible explanation), name the active status
    # filter and link to the unfiltered view instead. No override when already viewing "All".
    def empty_state_message
      return nil if current_transfer_status == 'all'
      link = view_context.link_to('view all transfers', quick_filter_all_statuses_url)
      "No #{current_transfer_status} transfers found, #{link}.".html_safe
    end

    def get_items
      @items = base_transfer_scope.order(sort_param)
    end

    def valid_sort_attributes
      ['work_id', 'created_at', 'status', 'organization_transfer', 'fulfillment_date']
    end

    def default_sort_param
      'created_at DESC'
    end

    def valid_filter_attributes
      ['work_id', 'status', 'organization_transfer', 'sending_user_id', 'receiving_user_id', 'created_at_start', 'created_at_end']
    end

    # sending_user_id/receiving_user_id are submitted as ms_id(s) from the user-search widget (see
    # _search_form_fields), matching the userSearchMultiple convention used elsewhere (e.g.
    # admin/downloads, admin/requests) -- split comma-separated multi-selects into arrays before
    # filtering.
    def user_key_params
      ['sending_user_id', 'receiving_user_id']
    end

    # sending_user_id/receiving_user_id store users.id (see ProxyDepositRequest), unlike CartItem's
    # user_id which stores ms_id directly -- so the submitted ms_id(s) need resolving to users.id
    # inline via a subquery rather than a plain column match. The ::text cast matters:
    # proxy_deposit_requests.sending_user_id/receiving_user_id are character varying columns
    # (needed since the association is polymorphic), while users.id is bigint -- without the cast,
    # Postgres has no "character varying = bigint" operator and the query raises PG::UndefinedFunction.
    def filter_attribute_where_statements
      {
        'sending_user_id' => 'sending_user_id IN (SELECT id::text FROM users WHERE ms_id IN (?))',
        'receiving_user_id' => 'receiving_user_id IN (SELECT id::text FROM users WHERE ms_id IN (?))',
        'created_at_start' => 'created_at >= ?',
        'created_at_end' => 'created_at <= ?'
      }
    end

    def prepare_items_for_csv
      @items = @items.map do |item|
        {
          'id' => item.id,
          'work_id' => item.work_id,
          'from' => item.sending_user&.name,
          'to' => item.receiving_user&.name,
          'status' => item.status,
          'organization_transfer' => item.organization_transfer,
          'sender_comment' => item.sender_comment,
          'receiver_comment' => item.receiver_comment,
          'created_at' => item.created_at,
          'fulfillment_date' => item.fulfillment_date
        }
      end
    end

    private

      # Quick-filter buttons handle status/organization_transfer without opening the full search
      # pane, so a default status filter alone shouldn't cause the search form to render open.
      def search_form_present?
        return true if params[:search].present? || params[:commit] == 'Search'
        (params[:filter_items] || {}).except('status', 'organization_transfer').values.any?(&:present?)
      end

      # Defaults the status quick-filter to "pending" unless the user picked a status explicitly
      # or asked to see all statuses. Uses string keys throughout so this composes cleanly with
      # both parsed query-string params (ActionController::Parameters) and this default (a Hash).
      def default_transfer_status_filter
        return if params[:all_statuses] == 'true'
        return if params.dig(:filter_items, 'status').present?
        params[:filter_items] = (params[:filter_items] || {}).merge('status' => 'pending')
      end

      def set_has_organization_transfers
        @has_organization_transfers = base_transfer_scope.where(organization_transfer: true).exists?
      end

      # Current filter_items as a plain, string-keyed Hash, regardless of whether it originated
      # from a real query string (ActionController::Parameters) or our own default Hash.
      def current_filter_items
        raw = params[:filter_items] || {}
        (raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw).stringify_keys
      end

      def quick_filter_status_url(status)
        url_for(request.params.merge(filter_items: current_filter_items.merge('status' => status), all_statuses: nil))
      end

      def quick_filter_all_statuses_url
        url_for(request.params.merge(filter_items: current_filter_items.except('status'), all_statuses: true))
      end

      def quick_filter_organization_transfer_url(value)
        filter_items = value.nil? ? current_filter_items.except('organization_transfer') : current_filter_items.merge('organization_transfer' => value)
        url_for(request.params.merge(filter_items: filter_items, all_statuses: params[:all_statuses]))
      end

      def batch_ids
        Array(params[:batch_document_ids]).uniq
      end

      # Loads the selected, still-pending requests and drops any the current user isn't
      # authorized for (rather than 403ing the whole batch over a stale/tampered id).
      def pending_requests_for_batch(ability_action)
        ProxyDepositRequest.where(id: batch_ids, status: 'pending').select { |r| can?(ability_action, r) }
      end

      # Records each request's decision immediately (fast; closes the window where a second
      # decision on the same request could be submitted while it still looks "pending") and, for
      # accept only, enqueues TransferDecisionJob to apply the slower ownership/permission side
      # effects afterward. Reject/cancel/force_cancel have no slow side effects, so they're applied
      # synchronously here and never enqueued.
      #
      # force_cancel (which bypasses ProxyDepositRequest's "senders can't cancel an organization
      # transfer" validation) is only used for admins -- matching Hyrax::TransfersController#destroy
      # -- so a regular sender's own batch_cancel still can't force through an organization
      # transfer; that request is left pending and logged rather than raising and aborting the rest
      # of the batch, since this now runs synchronously in the request cycle instead of in a job
      # that would have failed in isolation.
      def process_batch_decisions(requests, decision, reset: false, sticky: false, comment: nil)
        requests.each do |r|
          case decision.to_s
          when 'accept'
            r.record_decision!(status: 'accepted')
            TransferDecisionJob.perform_later(r.id, 'accept', acting_user_id: current_user.id, reset: reset, sticky: sticky)
          when 'reject'
            r.reject!(comment)
          when 'cancel'
            (r.organization_transfer? && current_user.admin?) ? r.force_cancel! : r.cancel!
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Batch #{decision} failed for ProxyDepositRequest##{r.id}: #{e.message}")
        end
      end

      # Flashes a red error (matching previous_requests#edit_expiration's "No requests selected"
      # pattern) instead of a bland success notice when the "Decide Selected" modal is submitted
      # with nothing checked, or the selected rows are no longer eligible (already decided, stale
      # page, etc).
      def redirect_with_batch_notice(requests, fallback, success_message:)
        if requests.empty?
          flash[:error] = "No transfers selected."
        else
          flash[:notice] = success_message
        end
        redirect_to redirect_target(fallback)
      end

      # Batch-decide buttons carry the page's current filters (status/type/etc.) as a return_to
      # param (see _list_actions) rather than depending on the Referer header, which isn't always
      # sent (browser privacy settings, extensions, some proxies) -- without this, every batch
      # decision bounced the user back to the unfiltered index. Only same-app relative paths are
      # accepted, so a crafted return_to can't be used as an open redirect.
      def redirect_target(fallback)
        return_to = params[:return_to]
        if return_to.present? && return_to.start_with?('/') && !return_to.start_with?('//')
          return_to
        else
          request.referer || fallback
        end
      end
  end
end
