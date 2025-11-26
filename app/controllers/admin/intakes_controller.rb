module Admin
  class IntakesController < ApplicationController
    before_action :require_admin
    before_action :set_intake, only: [:show, :convert]
    before_action :ensure_unprocessed!, only: [:convert]

    def index
      @intakes = Intake.order(created_at: :desc).includes(:created_user, :processed_by)
    end

    def show
      setup_form_context
    end

    def convert
      @generated_password = params.dig(:user, :password).presence || SecureRandom.base58(12)
      @welcome_subject = params[:welcome_subject]
      @welcome_message = params[:welcome_message]
      @user = build_user_from_params
      setup_form_context
      @user.password = @generated_password
      @user.password_confirmation = @generated_password
      @user.roles = ['user']

      if @user.save
        attach_group(@user)
        mark_intake_processed(@user)
        send_welcome_email(@user) if params[:send_welcome_email] == '1'
        redirect_to admin_intake_path(@intake), notice: "Nieuwe loper #{@user.name} is aangemaakt."
      else
        flash.now[:alert] = 'Opslaan mislukt. Controleer de invoer.'
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_intake
      @intake = Intake.find(params[:id])
    end

    def ensure_unprocessed!
      if @intake.processed?
        redirect_to admin_intake_path(@intake), alert: 'Deze intake is al verwerkt.' and return
      end
    end

    def setup_form_context
      @groups ||= Group.order(:name)
      @statuses ||= Status.order(:name)
      @default_group ||= @groups.find { |g| g.name == 'GAC AB Groep' } || @groups.first
      @default_status ||= @statuses.find { |s| s.name.downcase == 'actief' } || @statuses.first
      @generated_password ||= SecureRandom.base58(12)
      @user ||= build_user_from_intake
      @selected_group_id ||= @default_group&.id
      @welcome_subject ||= "Welkom bij Hardlopen met Virgil"
      @welcome_message ||= default_welcome_message(@user, @generated_password)
    end

    def build_user_from_intake
      User.new(
        name: "#{@intake.first_name} #{@intake.last_name}".squish,
        email: @intake.email,
        phone: @intake.emergency_number,
        emergency_contact: @intake.emergency_number,
        birthday: @intake.birthdate,
        injury: @intake.injuries,
        training_days: %w[Dinsdag Zaterdag],
        status: @default_status
      )
    end

    def build_user_from_params
      permitted = params.require(:user).permit(:name, :email, :phone, :emergency_contact, :birthday, :injury, :status_id, :group_id, training_days: [])
      permitted[:training_days] = sanitize_training_days(permitted[:training_days])
      permitted[:status_id] = permitted[:status_id].presence || @default_status&.id
      @selected_group_id = permitted[:group_id].presence || @default_group&.id
      User.new(permitted.except(:group_id))
    end

    def attach_group(user)
      group_id = params[:user][:group_id]
      return if group_id.blank?

      group = Group.find_by(id: group_id)
      return unless group

      group.users << user unless user.groups.include?(group)
    end

    def mark_intake_processed(user)
      @intake.update!(
        processed_at: Time.current,
        processed_by: current_user,
        created_user: user
      )
    end

    def send_welcome_email(user)
      subject = params[:welcome_subject].presence || "Welkom bij Hardlopen met Virgil"
      body = params[:welcome_message].presence || default_welcome_message(user, @generated_password)
      UserMailer.custom_welcome(user, subject, body, @generated_password).deliver_later
    end

    def default_welcome_message(user, password)
      <<~MSG
        Hoi #{user.name.split.first},

        Welkom bij de GAC AB Groep! Je account is aangemaakt. Je kunt inloggen via https://hardlopen.metvirgil.nl/login

        E-mailadres: #{user.email}
        Tijdelijk wachtwoord: #{password}

        Pas je wachtwoord na het inloggen direct aan via je profiel. We zien je graag op dinsdag en zaterdag op de baan.

        Sportieve groet,
        Team Hardlopen met Virgil
      MSG
    end

    def sanitize_training_days(days)
      selected = Array(days).reject(&:blank?)
      selected = %w[Dinsdag Zaterdag] if selected.empty?
      selected
    end
  end
end

