class AddTrainingDaysToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :training_days, :string, array: true, default: []
  end
end 