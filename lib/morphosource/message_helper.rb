module Morphosource
  module MessageHelper

    def host_name
      @host_name ||= Hyrax.config.host_name
    end

    def email_sender
      @email_sender ||= User.where(email: Hyrax.config.contact_email)&.first
    end

    def user_email_link(users)
      Array(users).map do |user|
        single_user_link(user)
      end.compact.to_sentence.html_safe
    end

    def user_or_org_email_link(user_or_org)
      Array(user_or_org).map do |single_user_or_org|
        if single_user_or_org.is_a? User
          single_user_link(single_user_or_org)
        elsif single_user_or_org.is_a? OrganizationCollection
          single_org_link(single_user_or_org)
        end
      end.compact.to_sentence.html_safe
    end

    def single_org_link(org)
      ActionController::Base.helpers.link_to(
        ActionController::Base.helpers.sanitize(org.name),
        Rails.application.routes.url_helpers.organization_url(org, host: host_name)
      ).html_safe
    end

    def single_user_link(user)
      ActionController::Base.helpers.link_to(
        ActionController::Base.helpers.sanitize(user.name),
        Hyrax::Engine.routes.url_helpers.user_url(user, host: host_name)
      ).html_safe
    end

	  def deliver_message(sender, recipients, message, subject)
	    begin
	      Hyrax::MessengerService.deliver(sender, recipients, message, subject)
	      # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
	    rescue => e
        Rails.logger.debug "Error sending message. Exception: #{ e.message }.  Make sure sender account in MS and HOST_NAME in environment is setup correctly."
	    end
	  end

	end
end