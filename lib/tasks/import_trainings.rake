# lib/tasks/import_trainings.rake
require 'csv'
require 'fileutils'

namespace :import do
  desc "Importeer trainingen uit app/Imports/trainingsschema_importklaar.csv (groep en individueel)"

  task trainings: :environment do
    require 'csv'

    file_path = Rails.root.join('app', 'Imports', 'trainingsschema_importklaar.csv')

    unless File.exist?(file_path)
      puts "❌ Bestand niet gevonden: #{file_path}"
      exit 1
    end

    puts "Importeren vanuit: #{file_path}"

    CSV.foreach(file_path, headers: true) do |row|
      title = row['title']&.strip
      description = row['description']&.strip
      date = row['date']&.strip
      email = row['email']&.strip

      user = email.present? ? User.find_by(email: email) : nil

      training = Training.find_or_initialize_by(
        title: title,
        date: date,
        user: user
      )
      training.description = description

      if training.new_record?
        begin
          training.save!
          puts "✅ Aangemaakt: #{title} op #{date} voor #{user ? user.email : 'groep'}"
        rescue => e
          puts "❌ Fout bij #{title} op #{date} (#{email}): #{e.message}"
        end
      else
        puts "ℹ️ Bestond al: #{title} op #{date} voor #{user ? user.email : 'groep'}"
      end

      # Trainers koppelen op basis van kolommen trainer_dinsdag en trainer_zaterdag
      ["trainer_dinsdag", "trainer_zaterdag"].each do |kolom|
        trainer_email = row[kolom]&.strip
        next unless trainer_email.present?

        trainer = User.find_by(email: trainer_email)
        unless trainer
          puts "⚠️ Geen user gevonden voor #{trainer_email} (kolom: #{kolom})"
          next
        end

        rol = kolom.gsub("trainer_", "") # "dinsdag" of "zaterdag"
        ta = TrainingAssignment.find_or_create_by!(training: training, user: trainer) do |ta|
          ta.rol = rol
        end
        puts "👤 Trainer #{trainer.email} gekoppeld aan #{training.title} als #{rol}"
      end
    end

    puts "✅ Import klaar"
  end
end
