class UpdatePhotosTable < ActiveRecord::Migration[7.1]
  def change
    rename_column :photos, :training_id, :training_session_id
    remove_foreign_key :photos, :trainings if foreign_key_exists?(:photos, :trainings)
    add_foreign_key :photos, :training_sessions, column: :training_session_id
  end
end
