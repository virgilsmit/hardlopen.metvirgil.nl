class CreateAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :training, null: false, foreign_key: true
      t.string :status, default: 'afwezig'
      t.timestamps
    end
  end
end
