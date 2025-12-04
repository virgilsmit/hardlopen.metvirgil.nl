class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.date :date
      t.string :location
      t.string :distance
      t.text :description
      t.string :url
      t.string :organizer
      t.string :price
      t.date :registration_deadline
      t.boolean :visible
      t.boolean :published

      t.timestamps
    end
  end
end
