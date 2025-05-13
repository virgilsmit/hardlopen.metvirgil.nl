class CreateTrainingDrills < ActiveRecord::Migration[7.1]
  def change
    create_table :training_drills do |t|
      t.references :training, null: false, foreign_key: true
      t.references :drill, null: false, foreign_key: true

      t.timestamps
    end
  end
end
