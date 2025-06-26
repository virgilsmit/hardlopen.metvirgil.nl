class AddTrainerIdToTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :training_sessions, :trainer_id, :bigint
  end
end
