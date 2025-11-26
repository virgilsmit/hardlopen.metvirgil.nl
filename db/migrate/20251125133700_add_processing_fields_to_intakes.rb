class AddProcessingFieldsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_reference :intakes, :created_user, foreign_key: { to_table: :users }
    add_reference :intakes, :processed_by, foreign_key: { to_table: :users }
    add_column :intakes, :processed_at, :datetime
  end
end





