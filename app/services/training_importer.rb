class TrainingImporter
  def initialize(csv_path)
    @csv_path = csv_path
  end

  def import
    require 'csv'
    unless File.exist?(@csv_path)
      return 'CSV-bestand niet gevonden.'
    end
    imported = 0
    errors = []
    group = Group.find_or_create_by!(name: 'GAC Recreanten AB')
    schema = TrainingSchema.find_or_create_by!(name: 'Standaard schema', group: group)
    date_regex = /\A\d{4}-\d{2}-\d{2}\z/
    CSV.foreach(@csv_path, headers: true) do |row|
      begin
        week = row['week']
        date = row['datum'] ? Date.parse(row['datum']) : nil
        dag = row['dag']
        training = row['training']
        loopscholing = row['loopscholing']
        trainer_email = row['trainer']
        fase = row['fase']
        wedstrijd = row['wedstrijd']
        trainer_user = nil
        if dag.to_s.downcase == 'dinsdag' || dag.to_s.downcase == 'zaterdag'
          trainer_user = User.find_by(email: trainer_email) if trainer_email.present?
        end
        TrainingSession.create!(
          training_schema: schema,
          group: group,
          week: week,
          date: date,
          dag: dag,
          description: training,
          loopscholing: loopscholing,
          trainer: trainer_user,
          fase: fase,
          wedstrijd: wedstrijd
        )
        imported += 1
      rescue => e
        errors << "Rij #{week} (#{row['datum']}): #{e.message}"
      end
    end
    "Import voltooid: #{imported} trainingen aangemaakt. Fouten: #{errors.join('; ')}"
  end
end 