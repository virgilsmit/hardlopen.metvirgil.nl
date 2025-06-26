class CreateTrainingAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :training_assignments do |t|
      t.references :training, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :rol

      t.timestamps
    end
  end
end
