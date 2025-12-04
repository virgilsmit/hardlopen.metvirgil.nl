class AddBottomNavToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :show_in_bottom_nav, :boolean, default: false
    add_column :tile_assignments, :bottom_nav_icon, :string
    add_column :tile_assignments, :bottom_nav_label, :string
    add_column :tile_assignments, :bottom_nav_position, :integer
    add_index :tile_assignments, [:role, :show_in_bottom_nav]
  end
end
