class AddTrainerToTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :training_sessions, :trainer, :string
  end
end 