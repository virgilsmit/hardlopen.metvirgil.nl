class TrainingScheduleParser
  Entry = Struct.new(
    :week, :date, :day, :training, :drills, :trainer, :phase, :race,
    keyword_init: true
  )

  def self.call(file_path)
    rows = read_rows(file_path)
    grouped = rows.group_by(&:week).sort_by { |week, _| week }.to_h

    {
      weeks: grouped.map do |week, entries|
        {
          week: week,
          label: "Week #{week}",
          dates: entries.map { |entry| entry.date },
          entries: entries
        }
      end,
      races: rows.select { |entry| entry.race.present? }
                 .map { |entry| { race: entry.race, date: entry.date } }
                 .uniq { |h| h[:race] },
      upcoming: rows.select { |entry| entry.date && entry.date >= Date.today }
                    .sort_by(&:date)
    }
  end

  def self.read_rows(file_path)
    require 'csv'
    csv = CSV.read(file_path, headers: true)
    csv.map do |row|
      Entry.new(
        week: row['week'].to_i,
        date: (Date.parse(row['datum']) rescue nil),
        day: row['dag'],
        training: row['training'],
        drills: row['loopscholing'],
        trainer: row['trainer'],
        phase: row['fase'],
        race: row['wedstrijd'].presence
      )
    end.compact
  end
  private_class_method :read_rows
end

