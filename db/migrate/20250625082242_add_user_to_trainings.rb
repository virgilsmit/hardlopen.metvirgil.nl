class AddUserToTrainings < ActiveRecord::Migration[7.1]
  def change
    add_reference :trainings, :user, null: true, foreign_key: true
  end
end
