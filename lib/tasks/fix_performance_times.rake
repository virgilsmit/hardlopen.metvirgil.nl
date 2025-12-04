namespace :performances do
  desc "Fix performance times: replace dots with colons in time values"
  task fix_times: :environment do
    puts "🔍 Checking for performances with dots in time values..."
    
    performances_with_dots = Performance.where("value LIKE '%._%._%'")
    count = performances_with_dots.count
    
    if count.zero?
      puts "✅ No performances found with dots in time values"
      exit
    end
    
    puts "📊 Found #{count} performance(s) with dots in time values"
    puts ""
    
    fixed = 0
    performances_with_dots.each do |perf|
      old_value = perf.value
      new_value = old_value.gsub('.', ':')
      
      perf.update_column(:value, new_value)
      
      user_name = perf.user&.name || "Unknown"
      puts "✓ Fixed Performance ##{perf.id} (#{user_name}): '#{old_value}' → '#{new_value}'"
      fixed += 1
    end
    
    puts ""
    puts "✅ Fixed #{fixed} performance(s)"
    puts "🔄 Reloading affected users' caches..."
    
    # Clear caches voor alle betrokken users
    performances_with_dots.map(&:user).uniq.compact.each do |user|
      user.clear_threshold_cache! if user.respond_to?(:clear_threshold_cache!)
      puts "  ✓ Cleared cache for #{user.name}"
    end
    
    puts ""
    puts "🎉 All done!"
  end
end

