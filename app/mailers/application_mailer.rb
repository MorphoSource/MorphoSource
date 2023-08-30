class ApplicationMailer < ActionMailer::Base
  default from: 'do.not.reply@morphosource.org'
  layout 'mailer'

  def send_email_with_attachment(email_address, subject, body, attachment_path)
    if attachment_path.present?
      file_name = File.basename(attachment_path)
      attachments[file_name] = File.read(attachment_path)
    end
    mail(to: email_address, subject: subject, body: body)
  end
end
