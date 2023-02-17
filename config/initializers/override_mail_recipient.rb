if Rails.env.development? or Rails.env.test?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.to = Hyrax.config.ms_dev_email
    end
    ActionMailer::Base.register_interceptor(OverrideMailRecipient)
  end
end
