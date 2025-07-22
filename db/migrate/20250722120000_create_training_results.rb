class CreateTrainingResults < ActiveRecord::Migration[7.0]
  def change
    create_table :training_results do |t|
      t.references :user, null: false, foreign_key: true
      t.references :training_session, null: false, foreign_key: true
      t.integer :time  # total duration in seconds
      t.float   :distance  # in kilometers
      t.text    :notes
      t.jsonb   :structured_core, default: [], null: false

      t.timestamps
    end

    add_index :training_results, :structured_core, using: :gin
  end
end 