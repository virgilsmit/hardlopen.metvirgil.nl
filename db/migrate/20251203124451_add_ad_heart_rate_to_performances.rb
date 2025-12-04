class AddAdHeartRateToPerformances < ActiveRecord::Migration[7.1]
  def change
    add_column :performances, :ad_heart_rate, :integer
  end
end
