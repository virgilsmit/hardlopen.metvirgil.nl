namespace :error_logs do
  desc "Verwijder opgeloste error logs ouder dan 30 dagen"
  task cleanup_resolved: :environment do
    cutoff_date = 30.days.ago
    deleted_count = ErrorLog.resolved.where('resolved_at < ?', cutoff_date).destroy_all.count
    puts "✓ #{deleted_count} opgeloste error logs verwijderd (ouder dan 30 dagen)"
  end

  desc "Verwijder alle error logs ouder dan 90 dagen"
  task cleanup_old: :environment do
    cutoff_date = 90.days.ago
    deleted_count = ErrorLog.where('created_at < ?', cutoff_date).destroy_all.count
    puts "✓ #{deleted_count} error logs verwijderd (ouder dan 90 dagen)"
  end

  desc "Toon statistieken van error logs"
  task stats: :environment do
    puts "═══════════════════════════════════════"
    puts "📊 ERROR LOGS STATISTIEKEN"
    puts "═══════════════════════════════════════"
    puts ""
    puts "Totaal:              #{ErrorLog.count}"
    puts "Onopgelost:          #{ErrorLog.unresolved.count}"
    puts "Opgelost:            #{ErrorLog.resolved.count}"
    puts ""
    puts "Vandaag:             #{ErrorLog.today.count}"
    puts "Deze week:           #{ErrorLog.this_week.count}"
    puts "Deze maand:          #{ErrorLog.this_month.count}"
    puts ""
    puts "Top 5 Fout Types:"
    ErrorLog.group(:error_class).count.sort_by { |k, v| -v }.first(5).each do |error_class, count|
      puts "  #{count}x #{error_class}"
    end
    puts ""
  end

  desc "Toon recente onopgeloste fouten"
  task recent_unresolved: :environment do
    puts "═══════════════════════════════════════"
    puts "🚨 RECENTE ONOPGELOSTE FOUTEN"
    puts "═══════════════════════════════════════"
    puts ""
    
    ErrorLog.unresolved.recent.limit(10).each do |log|
      puts "#{log.code} - #{log.error_class}"
      puts "  └─ #{log.error_message.truncate(80)}"
      puts "  └─ #{log.created_at.strftime('%d-%m-%Y %H:%M')}"
      puts ""
    end
  end
end

