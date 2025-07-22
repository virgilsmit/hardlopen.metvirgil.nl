#!/usr/bin/env ruby
require_relative '../config/environment'
require 'csv'

csv_path = Rails.root.join('app', 'Imports', 'Overzicht Lopers historie.csv')
raise "CSV-bestand niet gevonden: #{csv_path}" unless File.exist?(csv_path)

totaal = 0
zonder_user = 0
al_bestaand = 0
missende_namen = []

# Mapping voor speciale gevallen
SPECIAL_USER_MAP = {
  'Ollie' => 'oplantalech@gmail.com',
  'René' => 'r.matulewicz@chello.nl'
}

def parse_date(str)
  return nil unless str
  begin
    Date.strptime(str, '%d-%m-%y')
  rescue
    nil
  end
end

CSV.foreach(csv_path, col_sep: ';', headers: false).with_index do |row, idx|
  next if idx < 4 # Sla kopregels over
  naam = row[1]&.strip
  next unless naam.present?
  # Speciale mapping
  if SPECIAL_USER_MAP[naam]
    user = User.find_by(email: SPECIAL_USER_MAP[naam])
  else
    user = User.find_by(csv_name: naam) || User.where('name ILIKE ?', "%#{naam}%").first
  end
  unless user
    puts "Geen user gevonden voor: #{naam} (rij #{idx+1})"
    missende_namen << { naam: naam, rij: idx+1 }
    zonder_user += 1
    next
  end
  date = parse_date(row[2])
  distance = row[3].to_i
  value = row[4]
  test_type = row[0] || 'Onbekend'
  notes = "[import]"
  # Dubbele check: bestaat deze prestatie al voor deze user?
  bestaat = Performance.where(user_id: user.id, date: date, distance: distance, value: value).exists?
  if bestaat
    al_bestaand += 1
    next
  end
  perf = Performance.create!(
    user_id: user.id,
    test_type: test_type,
    distance: distance,
    value: value,
    date: date,
    notes: notes
  )
  totaal += 1
  puts "Toegevoegd: #{user.name} | #{date} | #{distance}m | #{value}"
end
puts "\nImport voltooid. Totaal toegevoegd: #{totaal}, overgeslagen (geen user): #{zonder_user}, al bestaand: #{al_bestaand}"
if missende_namen.any?
  puts "\nGeen user gevonden voor de volgende rijen:"
  missende_namen.each do |info|
    puts "- #{info[:naam]} (rij #{info[:rij]})"
  end
end 