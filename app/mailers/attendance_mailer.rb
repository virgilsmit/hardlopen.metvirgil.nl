class AttendanceMailer < ApplicationMailer
  default to: 'hardlopen@virgilsmit.com'

  def notify_change(attendance, actie)
    @attendance = attendance
    @user = attendance.user
    @training = attendance.training_session
    @actie = actie # 'afgemeld' of 'aangemeld'
    mail(
      subject: "#{@user.name} heeft zich #{@actie} voor training #{@training.date.strftime('%d-%m-%Y')}"
    )
  end
end 