namespace :events do
  desc "Importeer evenementen vanuit Loopjes 2026.xlsx"
  task import_loopjes: :environment do
    require 'roo'
    
    file_path = Rails.root.join('app', 'Imports', 'Loopjes 2026.xlsx')
    
    unless File.exist?(file_path)
      puts "❌ Bestand niet gevonden: #{file_path}"
      exit 1
    end
    
    puts "📊 Lezen van: Loopjes 2026.xlsx"
    xlsx = Roo::Spreadsheet.open(file_path.to_s)
    sheet = xlsx.sheet(0)
    
    puts "Aantal rijen: #{sheet.last_row}"
    puts "Aantal kolommen: #{sheet.last_column}"
    puts ""
    
    # Toon headers
    puts "Headers (rij 1):"
    (1..sheet.last_column).each do |col|
      puts "  Kolom #{col}: #{sheet.cell(1, col)}"
    end
    puts ""
    
    # Toon eerste event als voorbeeld
    if sheet.last_row >= 2
      puts "Eerste event (rij 2):"
      (1..sheet.last_column).each do |col|
        puts "  #{sheet.cell(1, col)}: #{sheet.cell(2, col)}"
      end
      puts ""
    end
    
    # Import - aangepast voor Loopjes 2026 formaat
    # Kolommen: Datum | Run | Informatie | Afstand
    puts "Importeren..."
    imported = 0
    errors = []
    
    (2..sheet.last_row).each do |i|
      begin
        # Kolom 1: Datum
        date_value = sheet.cell(i, 1)
        event_date = if date_value.is_a?(Date)
          date_value
        elsif date_value.is_a?(DateTime)
          date_value.to_date
        elsif date_value.present?
          Date.parse(date_value.to_s) rescue nil
        else
          nil
        end
        
        next if event_date.nil?
        
        # Kolom 2: Run (naam)
        name = sheet.cell(i, 2)&.to_s&.strip
        next if name.blank?
        
        # Kolom 3: Informatie (beschrijving)
        description = sheet.cell(i, 3)&.to_s&.strip
        
        # Kolom 4: Afstand
        distance = sheet.cell(i, 4)&.to_s&.strip
        
        # Probeer locatie uit naam te halen (eerste woord vaak locatie)
        location = name.split(' ').first
        
        event = Event.create!(
          name: name,
          date: event_date,
          location: location,
          distance: distance,
          description: description,
          organizer: nil,
          url: nil,
          price: nil,
          registration_deadline: nil,
          visible: true,
          published: true
        )
        
        puts "✓ Rij #{i}: #{event.name} op #{event.date.strftime('%d-%m-%Y')}"
        imported += 1
      rescue => e
        error_msg = "Rij #{i}: #{e.message}"
        puts "✗ #{error_msg}"
        errors << error_msg
      end
    end
    
    puts ""
    puts "═══════════════════════════════════════"
    puts "✅ Import voltooid!"
    puts "   Geïmporteerd: #{imported}"
    puts "   Fouten: #{errors.count}"
    puts "═══════════════════════════════════════"
    
    if errors.any?
      puts ""
      puts "Fouten:"
      errors.first(5).each { |e| puts "  - #{e}" }
    end
  end
end

