class AddCoreHeartRateToPerformances < ActiveRecord::Migration[7.1]
  def change
    add_column :performances, :core_heart_rate, :integer, null: true
  end
end
