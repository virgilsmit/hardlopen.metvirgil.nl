class CreateTrainings < ActiveRecord::Migration[7.1]
  def change
    create_table :trainings do |t|
      t.string :name, null: false
      t.text :description
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end