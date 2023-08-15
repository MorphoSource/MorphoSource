class ApplicationMailer < ActionMailer::Base
  default from: 'do.not.reply@morphosource.org'
  layout 'mailer'

  def send_email_with_attachment(email_address, subject, body, attachment_path)
    file_name = File.basename(attachment_path)
    attachments[file_name] = File.read(attachment_path)
    mail(to: email_address, subject: subject, body: body)
  end

  def send_email(email_address, subject, body)
    mail(to: email_address, subject: subject, body: body)
  end
end
