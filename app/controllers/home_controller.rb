class HomeController < ApplicationController
  def index
    if current_user
      today = Date.today
      @upcoming_birthdays = User.where.not(birthday: nil).sort_by do |user|
        bday = user.birthday.change(year: today.year)
        bday < today ? bday.next_year : bday
      end.first(3)
    else
      @upcoming_birthdays = []
    end
  end
end
