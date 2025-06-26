class CreateTrainingSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :training_sessions do |t|
      t.date :date
      t.text :description
      t.references :training_schema, null: false, foreign_key: true
      t.references :group, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
