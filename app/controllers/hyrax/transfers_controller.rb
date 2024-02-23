module Hyrax
  class TransfersController < ApplicationController
    before_action :authenticate_user!
    before_action :load_proxy_deposit_request, only: :create
    load_and_authorize_resource :proxy_deposit_request, parent: false, except: [:index, :batch_decide_transfers]
    before_action :authorize_depositor_by_id, only: [:new, :create]
    before_action :validate_decision_params, :validate_decision_type, :load_and_authorize_batch_transfers, only: [:batch_decide_transfers]
    with_themed_layout :decide_layout

    # Catch permission errors
    # TODO: Isn't this already handled?
    rescue_from CanCan::AccessDenied do |exception|
      if current_user&.persisted?
        redirect_to root_url, alert: exception.message
      else
        session["user_return_to"] = request.url
        redirect_to main_app.new_user_session_url, alert: exception.message
      end
    end

    def new
      #add_breadcrumb t(:'hyrax.controls.home'), root_path
      #add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      #add_breadcrumb t(:'hyrax.transfers.new.header'), hyrax.new_work_transfer_path
      @work = Hyrax::WorkRelation.new.find(params[:id])
    end

    def create
      @proxy_deposit_request.sending_user = current_user
      byebug
      if @proxy_deposit_request.save
        #redirect_to hyrax.transfers_path, notice: "Transfer request created"
        redirect_to main_app.media_showcase_edit_path(params[:id]), notice: "Transfer request has been sent."
      else
        #@work = Hyrax::WorkRelation.new.find(params[:id])
        #render :new
        redirect_to main_app.media_showcase_edit_path(params[:id]) + '#share', alert: "Sorry, transfer request was not sent.  Please make sure there is no pending request already, and also select a valid user with contributor access."
      end
    end

    def index
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyrax.admin.sidebar.transfers'), hyrax.transfers_path
      byebug
      @presenter = MsTransfersPresenter.new(current_user, view_context, request)
    end

    # Kicks of a job that completes the transfer. If params[:reset] is set, it will revoke
    # any existing edit permissions on the work.
    def accept
      @proxy_deposit_request.transfer!(params[:reset])
      # todo: might need to file a bug on this.  no need to add proxy user if the user is already in the proxy user list
      if params[:sticky]
        unless current_user.can_receive_deposits_from.include? @proxy_deposit_request.sending_user
          current_user.can_receive_deposits_from << @proxy_deposit_request.sending_user
        end
      end
      redirect_to hyrax.transfers_path, notice: "Transfer has been accepted."
    end

    def reject
      @proxy_deposit_request.reject!
      redirect_to hyrax.transfers_path, notice: "Transfer has been rejected."
    end

    def destroy
      @proxy_deposit_request.cancel!
      redirect_to hyrax.transfers_path, notice: "Transfer has been canceled."
    end

    def batch_decide_transfers
      unless @proxy_deposit_requests.present?
        redirect_to hyrax.transfers_path, alert: 'No transfers were selected.' and return
      end

      notice = ""
      if params[:decision] == 'accept'
        @proxy_deposit_requests.each do |proxy_deposit_request|
          proxy_deposit_request.transfer!(params[:reset])
          # todo: might need to file a bug on this.  no need to add proxy user if the user is already in the proxy user list
          if params[:sticky]
            unless current_user.can_receive_deposits_from.include? proxy_deposit_request.sending_user
              current_user.can_receive_deposits_from << proxy_deposit_request.sending_user
            end
          end
        end
        notice = "One or more transfers have been accepted. If this action included a large number of transfers, they may take a few moments to process."
      elsif params[:decision] == 'reject'
        @proxy_deposit_requests.each do |proxy_deposit_request|
          proxy_deposit_request.reject!
        end
        notice = "One or more transfers have been rejected. If this action included a large number of transfers, they may take a few moments to process."
      end

      redirect_to hyrax.transfers_path, notice: notice
    end

    private

      def authorize_depositor_by_id
        @id = params[:id]
        authorize! :transfer, @id
        @proxy_deposit_request.work_id = @id
      rescue CanCan::AccessDenied
        redirect_to root_url, alert: 'You are not authorized to transfer this work.'
      end

      def load_proxy_deposit_request
        @proxy_deposit_request = ProxyDepositRequest.new(proxy_deposit_request_params)
      end

      def proxy_deposit_request_params
        params.require(:proxy_deposit_request).permit(:transfer_to, :sender_comment)
      end

      def decide_layout
        layout = case action_name
                 when 'new'
                   'embedded_page'
                 else
                   'morphosource_dashboard'
                 end
        File.join(theme, layout)
      end

      def validate_decision_params
        params.require([:batch_transfers, :decision])
      end

      def validate_decision_type
        if !acceptable_decision_types.include?(params[:decision])
          redirect_to hyrax.transfers_path, alert: 'You did not submit an acceptable type of decision.'
        end
      end

      def acceptable_decision_types
        ['accept', 'reject']
      end

      def load_and_authorize_batch_transfers
        load_batch_transfers
        authorize_batch_transfers
      end

      def load_batch_transfers
        @proxy_deposit_requests =
          params[:batch_transfers]
          .map { |id| ProxyDepositRequest.find(id) }
      end

      def authorize_batch_transfers
        @proxy_deposit_requests.each { |req| authorize! params[:decision].to_sym, req }
      rescue CanCan::AccessDenied
        redirect_to root_url, alert: 'You are not authorized to transfer one or more works.'
      end
  end
end
