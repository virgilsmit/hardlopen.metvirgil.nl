class AddShowAppleWatchDownloadToTileAssignments < ActiveRecord::Migration[7.1]
  def change
    add_column :tile_assignments, :show_apple_watch_download, :boolean, default: false
  end
end
