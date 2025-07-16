module Hyrax
  class DepositorsController < ApplicationController
    include DenyAccessOverrideBehavior
    include Morphosource::Breadcrumbs

    before_action :authenticate_user!
    before_action :validate_users, only: :create

    layout :decide_layout

    PAGE_TITLE = I18n.t("morphosource.dashboard.my.proxies.page_title")

    def index
      @user = current_user
    end

    def create
      grantor = authorize_and_return_grantor
      grantee = ::User.from_url_component(params[:grantee_id])
      if grantor.can_receive_deposits_from.include?(grantee)
        # already a proxy user
        head :ok
      elsif !grantee.contributor?
        # not a contributor
        head :ok
      else
        grantor.can_receive_deposits_from << grantee
        begin
          send_proxy_depositor_added_messages(grantor, grantee)
        rescue => e
          Rails.logger.debug "Error sending message. Exception: #{ e.message }.  Make sure sender account in MS and HOST_NAME in environment is setup correctly."
        ensure
          render json: { name: grantee.name, delete_path: hyrax.user_depositor_path(grantor.user_key, grantee.user_key) }
        end
      end
    end

    def destroy
      grantor = authorize_and_return_grantor
      grantor.can_receive_deposits_from.delete(::User.from_url_component(params[:id]))
      head :ok
    end

    def validate_users
      head :ok if params[:user_id] == params[:grantee_id]
    end

    private

      def authorize_and_return_grantor
        grantor = ::User.from_url_component(params[:user_id])
        authorize! :edit, grantor
        grantor
      end

      def email_sender
        @email_sender ||= ::User.where(email: Hyrax.config.contact_email)&.first
      end

      def send_proxy_depositor_added_messages(grantor, grantee)
        message_to_grantee = "This message is to notify you that #{grantor.name} has assigned you as a proxy depositor."
        message_to_grantor = "This message is to notify you that you have assigned #{grantee.name} as a proxy depositor."
        # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
        Hyrax::MessengerService.deliver(email_sender, grantor, message_to_grantor, "You have added a proxy depositor")
        Hyrax::MessengerService.deliver(email_sender, grantee, message_to_grantee, "You have been added as a proxy depositor")
      end

      def decide_layout
        layout = case action_name
                 when 'index'
                   'morphosource_dashboard'
                 else
                   '1_column'
                 end
        File.join(theme, layout)
      end
  end
end
