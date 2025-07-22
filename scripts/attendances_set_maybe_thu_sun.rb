#!/usr/bin/env rails runner

# Zet alle aanwezigheden op donderdag en zondag op 'misschien' (status: onbekend)
puts "Start: alle aanwezigheden op donderdag en zondag op misschien zetten..."

trainings = TrainingSession.where.not(date: nil).find_all do |training|
  day = training.date.strftime('%A')
  day == 'Thursday' || day == 'Donderdag' || day == 'Sunday' || day == 'Zondag'
end
count = 0

trainings.each do |training|
  training.attendances.find_each do |attendance|
    attendance.status = :onbekend
    if attendance.changed?
      attendance.save!
      count += 1
      puts "Misschien gezet: user #{attendance.user_id} - training #{training.id} (#{training.date})"
    end
  end
end

puts "Klaar! Totaal #{count} aanwezigheden op misschien gezet." 