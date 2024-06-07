class TestMailer < ApplicationMailer
  def test_email
    mail(
      from: "morphosource.do.not.reply@duke.edu",
      to: "morphosource@duke.edu",
      subject: "Test mail",
      body: "Test mail body"
    )
  end
end
