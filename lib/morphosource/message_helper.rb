module Morphosource
  module MessageHelper

    def host_name
      @host_name ||= Hyrax.config.host_name
    end

    def email_sender
      # todo: look up sender from config instead
      @email_sender ||= User.where(email: 'morphosource@duke.edu')&.first
    end

    def user_email_link(users)
      list = []
      users.each do |user|
        list << "<a href='mailto:#{user.email}'>#{user.name_or_email}</a>"
      end
      return list.to_sentence.html_safe
    end

	  def deliver_message(sender, recipients, message, subject)
	    begin
	      Hyrax::MessengerService.deliver(sender, recipients, message, subject)
	      # arguments passed to messenger_service: (sender, recipients, body, subject, *args)
	    rescue => e
	      Rails.logger.debug "Error sending message. Exception: #{ e.message }"
	    end
	  end

	end
end