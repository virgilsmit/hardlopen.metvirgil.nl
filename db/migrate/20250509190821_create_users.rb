class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :emergency_contact
      t.date :birthday
      t.text :injury
      t.boolean :photo_permission

      t.timestamps
    end
  end
end
