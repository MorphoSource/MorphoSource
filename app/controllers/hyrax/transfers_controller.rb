module Hyrax
  class TransfersController < ApplicationController
    include Morphosource::Breadcrumbs

    before_action :authenticate_user!
    before_action :load_proxy_deposit_request, only: :create
    load_and_authorize_resource :proxy_deposit_request, parent: false, except: [:index]
    before_action :authorize_depositor_by_id, only: [:new, :create]
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

    PAGE_TITLE = I18n.t("hyrax.admin.sidebar.transfers")

    def new
      @work = Hyrax::WorkRelation.new.find(params[:id])
    end

    def create
      @proxy_deposit_request.sending_user = current_user
      if @proxy_deposit_request.save
        #redirect_to hyrax.transfers_path, notice: "Transfer request created"
        redirect_to main_app.media_showcase_edit_path(params[:id]), notice: "Transfer request has been sent."
      else
        #@work = Hyrax::WorkRelation.new.find(params[:id])
        #render :new
        redirect_to main_app.media_showcase_edit_path(params[:id]) + '#share', alert: "Sorry, transfer request was not sent.  Please make sure there is no pending request already, and also select a valid user with contributor access."
      end
    end

    # The Hyrax engine still routes GET dashboard/transfers here; redirect old bookmarks/links
    # to the new My Transfers Received page rather than 500ing with no #index defined.
    def index
      redirect_to main_app.transfers_received_path
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
      redirect_to redirect_target(main_app.transfers_received_path), notice: "Transfer has been accepted."
    end

    def reject
      @proxy_deposit_request.reject!
      redirect_to redirect_target(main_app.transfers_received_path), notice: "Transfer has been rejected."
    end

    # Admins may cancel an organization transfer (a regular sender cannot; the model validation
    # would raise), since the admin All Transfers page exists precisely for this kind of oversight.
    def destroy
      if @proxy_deposit_request.organization_transfer? && current_user.admin?
        @proxy_deposit_request.force_cancel!
      else
        @proxy_deposit_request.cancel!
      end
      redirect_to redirect_target(main_app.transfers_sent_path), notice: "Transfer has been canceled."
    end

    private

      # Per-row decide links carry the itemtable page's current filters as a return_to param (see
      # morphosource/*/_list_item) rather than depending on the Referer header, which isn't always
      # sent (browser privacy settings, extensions, some proxies) -- without this, deciding on
      # transfers one at a time bounced the user back to the unfiltered index each time. Only
      # same-app relative paths are accepted, so a crafted return_to can't be used as an open
      # redirect.
      def redirect_target(fallback)
        return_to = params[:return_to]
        if return_to.present? && return_to.start_with?('/') && !return_to.start_with?('//')
          return_to
        else
          request.referer || fallback
        end
      end

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
  end
end
