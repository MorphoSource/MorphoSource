class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "do.not.reply@morphosource.org",
      to: "morphosource@duke.edu",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
