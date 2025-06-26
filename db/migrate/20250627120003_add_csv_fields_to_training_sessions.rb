class AddCsvFieldsToTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :training_sessions, :week, :integer
    add_column :training_sessions, :dag, :string
    add_column :training_sessions, :loopscholing, :string
    add_column :training_sessions, :fase, :string
    add_column :training_sessions, :wedstrijd, :string
  end
end
