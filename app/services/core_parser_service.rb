class CoreParserService
  # Eenvoudige heuristische parser voor het tekstveld `core`.
  # 1. Herkent patronen als "3x1000m", "4x800 m", "2x5min".
  # 2. Herkent losse tijden zoals "2 min", "1 minuut".
  # 3. Detecteert intensiteit: laag, gemiddeld, hoog (default: gemiddeld).
  # Geeft een array met hashes terug.
  # Voorbeeld:
  #   CoreParserService.new("3x1000m op 10 km tempo, herstel 2 min laag").call
  # => [ {type:"interval", herhalingen:3, duur:"1000m", intensiteit:"gemiddeld"},
  #      {type:"herstel", herhalingen:1, duur:"2 min", intensiteit:"laag"} ]
  def initialize(text)
    @text = text.to_s.downcase
  end

  def call
    segments = []
    working_text = @text.dup

    # Speciaal patroon: "A min + pauze B min xN"
    working_text.scan(/(\d+)\s*min\s*\+\s*pauze\s*(\d+)\s*min\s*x\s*(\d+)/i).each do |a,b,n|
      working_text.sub!(/#{a}\s*min\s*\+\s*pauze\s*#{b}\s*min\s*x\s*#{n}/i,'')
      n.to_i.times do
        segments << { type:'duur', herhalingen:1, duur:"#{a}min", intensiteit: intensity_for_part(@text, detect_intensity(@text)) }
        segments << { type:'herstel', herhalingen:1, duur:"#{b}min", intensiteit: intensity_for_part(@text, detect_intensity(@text)) }
      end
    end

    intensity_global = detect_intensity(@text)

    # Splits de volledige tekst op + of komma (originele volgorde).
    working_text.split(/[,;+]/).each do |part|
      part.strip!
      next if part.empty?

      # Herken patronen in volgorde van specifiek naar algemeen.

      # 0. Specifiek patroon: A min + pauze B min xN (alternating)
      if m = part.match(/(\d+)\s*min\s*\+\s*pauze\s*(\d+)\s*min\s*x\s*(\d+)/)
        a = m[1].to_i
        b = m[2].to_i
        reps = m[3].to_i
        reps.times do
          segments << { type: 'duur', herhalingen: 1, duur: "#{a}min", intensiteit: intensity_for_part(part, intensity_global) }
          segments << { type: 'herstel', herhalingen: 1, duur: "#{b}min", intensiteit: intensity_for_part(part, intensity_global) }
        end
        next
      end

      # 1. N x Y eenheid (min/sec/km/m)
      if m = part.match(/(\d+)x\s*(\d+(?:[\.,]\d+)?)\s*(min|minuten|sec|s|seconden|km|m)/)
        unit = m[3].gsub('minuten','min').gsub('seconden','sec').gsub(/^s$/,'sec')
        segments << {
          type: part.include?('versnelling') ? 'versnelling' : (part.include?('interval') ? 'interval' : 'duur'),
          herhalingen: m[1].to_i,
          duur: "#{m[2]}#{unit}",
          intensiteit: intensity_for_part(part, intensity_global)
        }
        next
      end

      # 1b. Patroon: Y eenheid x N (herhaling achteraan)
      if m = part.match(/(\d+(?:[\.,]\d+)?)\s*(min|minuten|sec|s|seconden|km|m)\s*x\s*(\d+)/)
        unit = m[2].gsub('minuten','min').gsub('seconden','sec').gsub(/^s$/,'sec')
        segments << {
          type: part.include?('pauze') || part.include?('herstel') ? 'herstel' : (part.include?('versnelling') ? 'versnelling' : (part.include?('interval') ? 'interval' : 'duur')),
          herhalingen: m[3].to_i,
          duur: "#{m[1].gsub(',', '.')}#{unit}",
          intensiteit: intensity_for_part(part, intensity_global)
        }
        next
      end

      # 2. Losse afstand (km/m)
      if m = part.match(/(\d+(?:[\.,]\d+)?)\s*(km|m)/)
        segments << {
          type: part.include?('versnelling') ? 'versnelling' : (part.include?('interval') ? 'interval' : 'duur'),
          herhalingen: 1,
          duur: "#{m[1].gsub(',', '.')}#{m[2]}",
          intensiteit: intensity_for_part(part, intensity_global)
        }
        next
      end

      # 3. Losse tijd (min/sec)
      if m = part.match(/(\d+)\s*(min|minuten|sec|s|seconden)/)
        unit = m[2].gsub('minuten','min').gsub('seconden','sec').gsub(/^s$/,'sec')
        segments << {
          type: part.include?('herstel') ? 'herstel' : (part.include?('versnelling') ? 'versnelling' : (part.include?('interval') ? 'interval' : 'duur')),
          herhalingen: 1,
          duur: "#{m[1]}#{unit}",
          intensiteit: intensity_for_part(part, intensity_global)
        }
        next
      end
    end

    # (oude tweede parseloop verwijderd om duplicatie te voorkomen)

    segments.each do |seg|
      next unless seg[:duur]
      if (m = seg[:duur].match(/(\d+(?:[\.,]\d+)?)(min|sec|km|m|s)/))
        seg[:value] = m[1].gsub(',', '.').to_f
        seg[:unit]  = m[2]
      end
    end

    segments
  end

  private

  def intensity_for_part(part, default)
    return "hoog" if part.include?("hoog") || part.include?("sprint") || part.include?("versnelling")
    return "laag" if part.include?("laag") || part.include?("rustig") || part.include?("herstel")
    default
  end

  def detect_intensity(text)
    return "hoog" if text.include?("hoog") || text.include?("sprint") || text.include?("versnelling")
    return "laag" if text.include?("laag") || text.include?("rustig") || text.include?("herstel")
    "gemiddeld"
  end
end 