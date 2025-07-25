class CreateStatuses < ActiveRecord::Migration[7.1]
  def change
    create_table :statuses do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
    add_index :statuses, :name, unique: true
  end
end
