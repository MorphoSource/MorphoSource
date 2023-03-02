if Hyrax.config.override_mail_recipient.present?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.to = Hyrax.config.override_mail_recipient
    end
    ActionMailer::Base.register_interceptor(OverrideMailRecipient)
  end
end
