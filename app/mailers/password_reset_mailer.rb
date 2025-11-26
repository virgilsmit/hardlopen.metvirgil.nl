class PasswordResetMailer < ApplicationMailer
  def reset_email(user)
    @user = user
    @token = @user.reset_password_token
    mail(to: @user.email, subject: 'Wachtwoord reset instructies')
  end
end 