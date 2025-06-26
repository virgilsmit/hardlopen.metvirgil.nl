class UpdateTrainingDrillsTable < ActiveRecord::Migration[7.1]
  def change
    rename_column :training_drills, :training_id, :training_session_id
    remove_foreign_key :training_drills, :trainings if foreign_key_exists?(:training_drills, :trainings)
    add_foreign_key :training_drills, :training_sessions, column: :training_session_id
  end
end
