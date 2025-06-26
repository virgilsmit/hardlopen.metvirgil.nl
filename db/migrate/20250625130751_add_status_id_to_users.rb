class AddStatusIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :status_id, :integer
  end
end
