# Shared ItemTable wiring for the three ownership-transfer dashboards (My Transfers Received,
# My Transfers Sent, Admin All Transfers). Provides: a default "pending" status quick-filter so
# unresolved requests aren't buried among old ones, an @has_organization_transfers flag used to
# conditionally render the organization-transfer quick-filter toggle, and shared batch-decision
# helpers that hand work off to TransferDecisionJob instead of processing inline.
module Morphosource
  module TransfersItemtableBehavior
    extend ActiveSupport::Concern

    included do
      prepend_before_action :default_transfer_status_filter, only: [:index]
      before_action :set_has_organization_transfers, only: [:index]
      helper_method :current_filter_items, :quick_filter_status_url, :quick_filter_all_statuses_url,
                    :quick_filter_organization_transfer_url
    end

    # Override in the including controller: the unfiltered, unpaginated base scope.
    def base_transfer_scope
      raise NotImplementedError, "#{self.class} must implement #base_transfer_scope"
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
      ['work_id', 'status', 'organization_transfer', 'sending_user_id', 'receiving_user_id']
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

      def enqueue_transfer_decisions(requests, decision, **opts)
        requests.each { |r| TransferDecisionJob.perform_later(r.id, decision, acting_user_id: current_user.id, **opts) }
      end
  end
end
