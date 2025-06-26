class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :end_time
      t.string :trainer_name
      t.date :date
      t.time :time
      t.string :training_type
      t.string :location
      t.string :trainer

      t.timestamps
    end
  end
end
