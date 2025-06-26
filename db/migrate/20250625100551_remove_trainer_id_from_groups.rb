class RemoveTrainerIdFromGroups < ActiveRecord::Migration[7.1]
  def change
    remove_column :groups, :trainer_id, :integer
  end
end
