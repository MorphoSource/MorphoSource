module Morphosource
  module MessageHelper

    def host_name
      @host_name ||= Hyrax.config.host_name
    end

    def email_sender
      @email_sender ||= User.where(email: Hyrax.config.contact_email)&.first
    end

    def user_email_link(users)
      list = []
      users.each do |user|
        raise "Unexpected OrganizationCollection in place of User" if user.is_a? OrganizationCollection
        list << "<a href='mailto:#{user.email}'>#{user.name_or_email}</a>"
      end
      return list.to_sentence.html_safe
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