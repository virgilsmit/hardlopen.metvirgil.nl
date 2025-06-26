class CreatePresences < ActiveRecord::Migration[7.1]
  def change
    create_table :presences do |t|
      t.references :session, null: false, foreign_key: true
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.boolean :status

      t.timestamps
    end
  end
end
