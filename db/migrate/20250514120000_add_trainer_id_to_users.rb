class AddTrainerIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :trainer, foreign_key: { to_table: :users }, index: true
  end
end
