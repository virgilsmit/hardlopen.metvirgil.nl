class AddShowInMenuToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :show_in_menu, :boolean
  end
end
