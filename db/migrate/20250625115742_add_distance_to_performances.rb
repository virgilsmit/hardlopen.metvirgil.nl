class AddDistanceToPerformances < ActiveRecord::Migration[7.1]
  def change
    add_column :performances, :distance, :integer
  end
end
