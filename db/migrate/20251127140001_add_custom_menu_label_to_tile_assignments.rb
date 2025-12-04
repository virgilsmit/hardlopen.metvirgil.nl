class AddCustomMenuLabelToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :custom_menu_label, :string
  end
end











