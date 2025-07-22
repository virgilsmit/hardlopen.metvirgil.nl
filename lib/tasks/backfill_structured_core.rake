namespace :training_sessions do
  desc 'Backfill structured_core for existing records'
  task backfill_structured_core: :environment do
    TrainingSession.find_each do |ts|
      text = ts.respond_to?(:core) ? (ts.core || '') : (ts.description || '')
      ts.update_columns(structured_core: CoreParserService.new(text).call)
    end
    puts 'Backfill completed.'
  end
end 