class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "info@morphosource.org",
      to: "info@morphosource.org",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
