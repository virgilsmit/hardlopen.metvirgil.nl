class CreateIntakes < ActiveRecord::Migration[7.1]
  def change
    create_table :intakes do |t|
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.string  :email, null: false
      t.date    :birthdate, null: false
      t.string  :gender, null: false
      t.string  :emergency_number, null: false
      t.text    :loop_experience
      t.string  :desired_pace
      t.integer :cooper_test_meters
      t.text    :goal_2025
      t.string  :shirt_size, null: false
      t.text    :injuries
      t.text    :comments

      t.timestamps
    end
  end
end





