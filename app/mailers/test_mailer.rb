class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "morphosource@duke.org",
      to: "morphosource@duke.org",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
