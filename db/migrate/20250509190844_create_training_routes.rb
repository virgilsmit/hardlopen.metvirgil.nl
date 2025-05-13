class CreateTrainingRoutes < ActiveRecord::Migration[7.1]
  def change
    create_table :training_routes do |t|
      t.references :training, null: false, foreign_key: true
      t.references :route, null: false, foreign_key: true

      t.timestamps
    end
  end
end
