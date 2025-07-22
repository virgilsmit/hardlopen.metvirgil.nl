class CreateTileAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :tile_assignments do |t|
      t.string :role
      t.string :tile_key
      t.boolean :visible

      t.timestamps
    end
  end
end
