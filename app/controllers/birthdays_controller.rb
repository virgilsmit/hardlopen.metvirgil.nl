class BirthdaysController < ApplicationController
  # Publiek toegankelijk: overzicht komende 30 dagen
  def index
    today = Date.today
    @upcoming_birthdays = User.where.not(birthday: nil).select do |user|
      bday_this_year = user.birthday.change(year: today.year)
      bday_this_year += 1.year if bday_this_year < today
      (bday_this_year - today).to_i <= 30
    end.sort_by do |user|
      bday = user.birthday.change(year: today.year)
      bday += 1.year if bday < today
      bday
    end
  end
end 