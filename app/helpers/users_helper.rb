module UsersHelper
  require 'csv'

  # Geeft een array van hashes met relevante tijden voor de loper
  def lopers_historie_for(user)
    file = Rails.root.join('app', 'Imports', 'Overzicht Lopers historie.csv')
    return [] unless File.exist?(file)
    data = []
    zoeknaam = user.csv_name.presence || user.name.split.first
    CSV.foreach(file, col_sep: ';', headers: false).with_index do |row, idx|
      next if idx < 4 # Sla kopregels over
      naam = row[1]&.strip
      next unless naam&.casecmp(zoeknaam.strip) == 0
      data << {
        datum: row[2],
        afstand: row[3],
        tijd: row[4],
        prognose_10km: row[5],
        ad: row[6],
        dl2_85: row[8],
        km_min: row[21]
      }
    end
    data
  end
end
