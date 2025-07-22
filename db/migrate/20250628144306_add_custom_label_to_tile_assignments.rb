class AddCustomLabelToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :custom_label, :string
  end
end
