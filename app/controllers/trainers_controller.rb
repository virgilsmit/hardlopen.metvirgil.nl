class TrainersController < ApplicationController
  before_action :require_trainer_or_admin

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

  private
  def require_trainer_or_admin
    unless current_user&.role.in?(["trainer", "admin"])
      redirect_to root_path, alert: 'Alleen trainers en beheerders mogen deze pagina zien.'
    end
  end
end 