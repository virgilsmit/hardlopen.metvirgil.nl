class AddKernFieldsToTrainingSchemas < ActiveRecord::Migration[7.1]
  def change
    add_column :training_schemas, :dinsdag_interval, :string
    add_column :training_schemas, :zaterdag_duurloop, :string
  end
end
