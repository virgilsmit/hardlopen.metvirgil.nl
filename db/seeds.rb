# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

# Import lopers from CSV file
csv_file_path = File.join(__dir__, 'Import Lopers Jan 2025.csv')

# Ensure the group exists
lopers_group = Group.find_or_create_by!(name: 'GAC Recreanten AB')

CSV.foreach(csv_file_path, headers: true, col_sep: ';') do |row|
  user = User.find_or_initialize_by(email: row['E-mail'])
  voornaam = row['Voornaam'].to_s.strip
  achternaam = row['Achternaam'].to_s.strip
  full_name = "#{voornaam} #{achternaam}".strip
  user.name = full_name.presence || row['E-mail']
  user.birthday = Date.strptime(row['Geboortedatum'], '%d-%m-%Y')
  user.emergency_contact = row['Noodnummer']
  user.injury = row['Onderliggende/bekende blessures']
  user.phone = row['Noodnummer']
  user.password = 'welkom2025'
  user.password_confirmation = 'welkom2025'
  user.group = lopers_group # Associate with the group
  user.save!
end
