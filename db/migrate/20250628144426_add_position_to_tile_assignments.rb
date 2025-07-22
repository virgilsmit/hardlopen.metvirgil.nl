class AddPositionToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :position, :integer
  end
end
