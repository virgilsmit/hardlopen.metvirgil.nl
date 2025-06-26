class CreateTrainingSchemas < ActiveRecord::Migration[7.1]
  def change
    create_table :training_schemas do |t|
      t.string :name
      t.text :description
      t.references :group, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
