class UserMailer < ApplicationMailer
  def custom_welcome(user, subject, body, password)
    @user = user
    @body = body
    @password = password
    mail(to: @user.email, subject: subject)
  end
end

