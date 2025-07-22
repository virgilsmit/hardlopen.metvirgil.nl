class PublicRunnersController < ApplicationController
  protect_from_forgery except: :afmelden

  def afmelden
    @user = User.find_by(slug: params[:slug], public_token: params[:token])
    unless @user
      render plain: 'Ongeldige link of loper niet gevonden.', status: :not_found and return
    end

    today = Date.today
    @training_session = TrainingSession.find_by(date: today)
    unless @training_session
      render plain: 'Er is vandaag geen training gevonden.', status: :not_found and return
    end

    @attendance = Attendance.find_or_initialize_by(user: @user, training_session: @training_session)

    if request.post?
      nieuwe_status = params[:aanmelden] ? 'aanwezig' : 'afwezig'
      @attendance.status = nieuwe_status
      @attendance.note = params[:reden] if nieuwe_status == 'afwezig'
      @attendance.save!
      # Mail en logging
      AttendanceMailer.notify_change(@attendance, nieuwe_status == 'afwezig' ? 'afgemeld' : 'aangemeld').deliver_later
      Rails.logger.info "Loper #{@user.name} heeft zich #{nieuwe_status} voor training #{@training_session.date} (reden: #{@attendance.note})"
      flash[:notice] = "Je bent nu als #{nieuwe_status} geregistreerd voor de training van vandaag."
      redirect_to public_afmelden_path(slug: @user.slug, token: @user.public_token) and return
    end
  rescue => e
    render plain: "Er is iets misgegaan: #{e.message}", status: :unprocessable_entity
  end
end 