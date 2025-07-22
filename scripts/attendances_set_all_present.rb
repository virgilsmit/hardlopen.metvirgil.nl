#!/usr/bin/env rails runner

# Zet alle lopers voor alle trainingen op aanwezig
puts "Start: alle lopers voor alle trainingen op aanwezig zetten..."

users = User.where(role: :user)
trainings = TrainingSession.all
count = 0

users.find_each do |user|
  trainings.find_each do |training|
    attendance = Attendance.find_or_initialize_by(user_id: user.id, training_session_id: training.id)
    attendance.status = :aanwezig
    if attendance.changed?
      attendance.save!
      count += 1
      puts "Aanwezigheid gezet: user #{user.id} (#{user.email}) - training #{training.id}"
    end
  end
end

puts "Klaar! Totaal #{count} aanwezigheden gezet." 