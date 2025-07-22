class AddLocationToTrainingSchemasAndSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :training_schemas, :location, :string
    add_column :training_sessions, :location, :string
  end
end
