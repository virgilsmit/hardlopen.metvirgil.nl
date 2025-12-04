class AddOccurrenceTrackingToErrorLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :error_logs, :occurrence_count, :integer, default: 1, null: false
    add_column :error_logs, :last_occurrence_at, :datetime
    add_column :error_logs, :first_occurrence_at, :datetime
    
    # Update existing records
    reversible do |dir|
      dir.up do
        ErrorLog.find_each do |log|
          log.update_columns(
            first_occurrence_at: log.created_at,
            last_occurrence_at: log.created_at
          )
        end
      end
    end
  end
end
