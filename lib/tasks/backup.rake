namespace :db do
  desc "Backup database to specified file"
  task :backup, [:output_file] => :environment do |t, args|
    require 'open3'
    
    output_file = args[:output_file] || "db/backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sql"
    db_config = ActiveRecord::Base.connection_db_config.configuration_hash
    
    cmd = ['pg_dump']
    cmd << '-h' << db_config[:host] if db_config[:host]
    cmd << '-p' << db_config[:port].to_s if db_config[:port]
    cmd << '-U' << db_config[:username] if db_config[:username]
    cmd << db_config[:database]
    
    env = {}
    env['PGPASSWORD'] = db_config[:password] if db_config[:password]
    
    puts "📊 Database backup maken naar: #{output_file}"
    output, stderr, status = Open3.capture3(env, *cmd)
    
    if status.success?
      File.write(output_file, output)
      size_mb = (File.size(output_file) / 1024.0 / 1024.0).round(2)
      puts "✅ Database backup succesvol: #{size_mb} MB"
      puts "📍 Locatie: #{File.expand_path(output_file)}"
    else
      puts "⚠️  Database backup mislukt"
      puts "Error: #{stderr}" if stderr.present?
    end
  end
end

