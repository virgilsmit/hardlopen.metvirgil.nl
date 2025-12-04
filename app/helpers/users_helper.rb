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

  # Zet tijd in "uu:mm:ss" om naar seconden
  def tijd_naar_seconden(tijd)
    return 0 unless tijd
    delen = tijd.split(":").map(&:to_i)
    case delen.size
    when 3 then delen[0]*3600 + delen[1]*60 + delen[2]
    when 2 then delen[0]*60 + delen[1]
    when 1 then delen[0]
    else 0
    end
  end

  # Zet seconden om naar "uu:mm:ss"
  def seconden_naar_tijd(seconden)
    return "" unless seconden
    h = seconden / 3600
    m = (seconden % 3600) / 60
    s = seconden % 60
    if h > 0
      "%02d:%02d:%02d" % [h, m, s]
    else
      "%02d:%02d" % [m, s]
    end
  end

  # Prognose 5 km volgens Riegel (exponent 1,06)
  def prognose_5km(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    prognose = tijd * (5000.0 / afstand) ** 1.06
    seconden_naar_tijd(prognose.round)
  end

  # Prognose 10 km volgens Riegel (exponent 1,06)
  def prognose_10km(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    prognose = tijd * (10000.0 / afstand) ** 1.06
    seconden_naar_tijd(prognose.round)
  end

  # Anarobe drempel (AD): tijd per km bij 90% van de gelopen snelheid
  def ad(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    snelheid = afstand / tijd # m/s
    snelheid_ad = snelheid * 0.9
    tijd_per_km = 1000.0 / snelheid_ad
    seconden_naar_tijd(tijd_per_km.round)
  end

  # Duurloop 85% (DL2_85): tijd per km bij 85% van de gelopen snelheid
  def dl2_85(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    snelheid = afstand / tijd # m/s
    snelheid_dl2 = snelheid * 0.85
    tijd_per_km = 1000.0 / snelheid_dl2
    seconden_naar_tijd(tijd_per_km.round)
  end

  # km/min: tijd per kilometer
  def km_min(performance)
    tijd = tijd_naar_seconden(performance.value)
    afstand = performance.distance.to_f
    return "" if tijd == 0 || afstand == 0
    tijd_per_km = tijd / (afstand / 1000.0)
    seconden_naar_tijd(tijd_per_km.round)
  end

  def gemiddelde_ad(performances)
    waardes = performances.map { |p| tijd_naar_seconden(ad(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end

  def gemiddelde_dl2_85(performances)
    waardes = performances.map { |p| tijd_naar_seconden(dl2_85(p)) }.select { |s| s > 0 }
    return '' if waardes.empty?
    seconden_naar_tijd((waardes.sum / waardes.size.to_f).round)
  end
end
