class FixTrainingsColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :trainings, :name, :title
    rename_column :trainings, :start_time, :date
    remove_column :trainings, :end_time, :datetime
  end
end
