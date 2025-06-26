class AddTrainersToGroups < ActiveRecord::Migration[7.1]
  def change
    add_reference :groups, :hoofdtrainer, foreign_key: { to_table: :users }
    add_reference :groups, :medetrainer, foreign_key: { to_table: :users }
  end
end
