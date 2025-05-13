class CreateTrainings < ActiveRecord::Migration[7.1]
  def change
    create_table :trainings do |t|
      t.date :date
      t.string :location
      t.text :notes

      t.timestamps
    end
  end
end
