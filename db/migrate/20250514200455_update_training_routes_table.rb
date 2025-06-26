class UpdateTrainingRoutesTable < ActiveRecord::Migration[7.1]
  def change
    rename_column :training_routes, :training_id, :training_session_id
    remove_foreign_key :training_routes, :trainings if foreign_key_exists?(:training_routes, :trainings)
    add_foreign_key :training_routes, :training_sessions, column: :training_session_id
  end
end
