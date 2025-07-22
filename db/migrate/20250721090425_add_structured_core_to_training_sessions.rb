class AddStructuredCoreToTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :training_sessions, :structured_core, :jsonb, default: [], null: false
    add_index :training_sessions, :structured_core, using: :gin
  end
end
