require_relative './config/environment'
require 'csv'

zomer = TrainingSchema.find_or_create_by!(name: 'Zomerschema 2025')
najaar = TrainingSchema.find_or_create_by!(name: 'Najaarsschema 2025')

zomer_dates = []
CSV.foreach('app/Imports/Zomerschema2025_DatesFixed.csv', headers: false) do |row|
  date = Date.parse(row[1]) rescue nil
  desc = row[2]
  title = row[2]
  if date
    zomer_dates << date
    TrainingSession.where(date: date).destroy_all
    zomer.training_sessions.create!(date: date, description: desc)
  end
end
zomer.training_sessions.where.not(date: zomer_dates).destroy_all

najaar_dates = []
CSV.foreach('app/Imports/Schema2dehelft2025_Ready.csv', headers: false) do |row|
  date = Date.parse(row[1]) rescue nil
  desc = row[2]
  title = row[2]
  if date
    najaar_dates << date
    TrainingSession.where(date: date).destroy_all
    najaar.training_sessions.create!(date: date, description: desc)
  end
end
najaar.training_sessions.where.not(date: najaar_dates).destroy_all

puts "Import en synchronisatie voltooid." 