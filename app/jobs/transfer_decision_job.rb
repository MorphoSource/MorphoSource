# Processes a single ProxyDepositRequest decision (accept/reject/cancel/force_cancel) out of band,
# so batch decisions on the transfers dashboards don't block the request/response cycle on
# ProxyDepositRequest#transfer!'s synchronous ContentDepositorChangeEventJob.perform_now call.
class TransferDecisionJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_fast_queue_name

  DECISIONS = %w[accept reject cancel force_cancel].freeze

  # @param proxy_deposit_request_id [Integer, String]
  # @param decision ['accept','reject','cancel','force_cancel']
  # @param acting_user_id [Integer, nil] id of the user who made the decision; only used for the
  #        "sticky proxy" side effect on accept
  # @param reset [Boolean] forwarded to ProxyDepositRequest#transfer! when decision == 'accept'
  # @param sticky [Boolean] if true and decision == 'accept', add sending_user to acting_user's
  #        can_receive_deposits_from list
  # @param comment [String, nil] forwarded to ProxyDepositRequest#reject!
  def perform(proxy_deposit_request_id, decision, acting_user_id: nil, reset: false, sticky: false, comment: nil)
    return unless DECISIONS.include?(decision.to_s)

    request = ProxyDepositRequest.find_by(id: proxy_deposit_request_id)
    return unless request&.pending? # already resolved (or gone); safe no-op

    case decision.to_s
    when 'accept'
      request.transfer!(reset)
      apply_sticky(request, acting_user_id) if sticky
    when 'reject'
      request.reject!(comment)
    when 'cancel'
      request.cancel!
    when 'force_cancel'
      request.force_cancel!
    end
  end

  private

    def apply_sticky(request, acting_user_id)
      acting_user = acting_user_id && User.find_by(id: acting_user_id)
      return unless acting_user
      return if acting_user.can_receive_deposits_from.include?(request.sending_user)
      acting_user.can_receive_deposits_from << request.sending_user
    end
end
