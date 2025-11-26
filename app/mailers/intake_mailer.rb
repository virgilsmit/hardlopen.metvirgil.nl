class IntakeMailer < ApplicationMailer
  default to: 'hardlopen@virgilsmit.com'

  def notify(intake)
    @intake = intake
    mail(subject: "Nieuwe intake: #{@intake.full_name}", reply_to: @intake.email)
  end
end





