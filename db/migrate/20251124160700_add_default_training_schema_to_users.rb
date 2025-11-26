class AddDefaultTrainingSchemaToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :default_training_schema, foreign_key: { to_table: :training_schemas }
  end
end






