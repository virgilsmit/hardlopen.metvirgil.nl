class PublicRunnersController < ApplicationController
  layout 'afmelden'
  protect_from_forgery except: :afmelden

  def afmelden
    @user = User.find_by(slug: params[:slug], public_token: params[:token])
    unless @user
      render plain: 'Ongeldige link of loper niet gevonden.', status: :not_found and return
    end

    # Handle webmanifest request
    if request.format.webmanifest?
      manifest = {
        name: "Afmelden - #{@user.name}",
        short_name: "Afmelden",
        description: "Snel afmelden voor je training zonder inloggen",
        start_url: public_afmelden_path(slug: @user.slug, token: @user.public_token),
        scope: "/",
        display: "standalone",
        background_color: "#FC4C02",
        theme_color: "#FC4C02",
        orientation: "portrait",
        categories: ["sports", "fitness", "lifestyle"],
        icons: [
          {
            src: "/icon-afmelden-192.png",
            sizes: "192x192",
            type: "image/png",
            purpose: "any"
          },
          {
            src: "/icon-afmelden-512.png",
            sizes: "512x512",
            type: "image/png",
            purpose: "any maskable"
          }
        ]
      }
      
      response.headers['Content-Type'] = 'application/manifest+json'
      render json: manifest
      return
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