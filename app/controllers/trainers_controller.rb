class TrainersController < ApplicationController
  before_action :require_trainer_or_admin, except: [:verjaardagen]

  def tijden
    @performance = Performance.new
  end

  def index
    today = Date.today
    @upcoming_birthdays = User.where.not(birthday: nil).sort_by do |user|
      bday = user.birthday.change(year: today.year)
      bday < today ? bday.next_year : bday
    end
  end

  def verjaardagen
    today = Date.today
    @upcoming_birthdays = User.where.not(birthday: nil).sort_by do |user|
      bday = user.birthday.change(year: today.year)
      bday < today ? bday.next_year : bday
    end
  end

  def beheer
    @trainers = User.with_role(:trainer).order(:name)
    @promoteable_lopers = User.with_role(:user).where.not("roles @> ARRAY[?]::varchar[]", 'trainer').order(:name)
  end

  def promote_trainer
    user = User.find(params[:user_id])
    user.add_role(:trainer)
    redirect_to trainers_beheer_path, notice: "#{user.name} is nu ook trainer."
  end

  def overzicht
    # Hier kunnen straks statistieken en overzichten geladen worden
  end

  def ad_gemiddelden
    @lopers = User.alleen_actieve_lopers.to_a.select { |u| u.gemiddelde_ad.present? && u.gemiddelde_ad != '' }
    @lopers.sort_by! { |u| u.tijd_naar_seconden(u.gemiddelde_ad) }
  end

  private
  def require_trainer_or_admin
    unless current_user&.has_role?(:trainer) || current_user&.has_role?(:admin)
      redirect_to root_path, alert: 'Alleen trainers en beheerders mogen deze pagina zien.'
    end
  end
end 