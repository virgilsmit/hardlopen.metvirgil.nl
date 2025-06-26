class CreateTrainingSchedules < ActiveRecord::Migration[7.1]
  def change
    create_table :training_schedules do |t|
      t.references :group, null: false, foreign_key: true
      t.integer :weekday
      t.time :start_time
      t.time :end_time
      t.string :location
      t.boolean :active

      t.timestamps
    end
  end
end
