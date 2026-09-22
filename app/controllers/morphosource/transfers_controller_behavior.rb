# Shared ItemTable wiring for the three ownership-transfer dashboards
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

    def entry_name
      'transfer'
    end

    def current_transfer_status
      params[:all_statuses] == 'true' ? 'all' : (params.dig(:filter_items, 'status') || 'pending')
    end

    def empty_state_message
      return nil if current_transfer_status == 'all'
      link = view_context.link_to(I18n.t('morphosource.transfers.view_all_link_text'), quick_filter_all_statuses_url)
      I18n.t('morphosource.transfers.empty_state_html', status: current_transfer_status, link: link).html_safe
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

    def user_key_params
      ['sending_user_id', 'receiving_user_id']
    end

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

      def search_form_present?
        return true if params[:search].present? || params[:commit] == 'Search'
        (params[:filter_items] || {}).except('status', 'organization_transfer').values.any?(&:present?)
      end

      def default_transfer_status_filter
        return if params[:all_statuses] == 'true'
        return if params.dig(:filter_items, 'status').present?
        params[:filter_items] = (params[:filter_items] || {}).merge('status' => 'pending')
      end

      def set_has_organization_transfers
        @has_organization_transfers = base_transfer_scope.where(organization_transfer: true).exists?
      end

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

      def pending_requests_for_batch(ability_action)
        ProxyDepositRequest.where(id: batch_ids, status: 'pending').select { |r| can?(ability_action, r) }
      end

      # Records each request's decision immediately and, for accept, enqueues TransferDecisionJob
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

      def redirect_with_batch_notice(requests, fallback, success_message:)
        if requests.empty?
          flash[:error] = I18n.t('morphosource.transfers.no_transfers_selected')
        else
          flash[:notice] = success_message
        end
        redirect_to redirect_target(fallback)
      end

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
