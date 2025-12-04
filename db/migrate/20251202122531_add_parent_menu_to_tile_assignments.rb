class AddParentMenuToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :parent_menu, :string
    add_column :tile_assignments, :show_in_parent_dropdown, :boolean, default: false
    add_column :tile_assignments, :show_as_shortcut, :boolean, default: false
    
    add_index :tile_assignments, :parent_menu
  end
end
