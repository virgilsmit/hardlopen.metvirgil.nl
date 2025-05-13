class CreatePerformances < ActiveRecord::Migration[7.1]
  def change
    create_table :performances do |t|
      t.references :user, null: false, foreign_key: true
      t.string :test_type
      t.string :value
      t.date :date
      t.text :notes

      t.timestamps
    end
  end
end
