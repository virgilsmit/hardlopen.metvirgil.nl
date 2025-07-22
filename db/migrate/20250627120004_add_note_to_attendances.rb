class AddNoteToAttendances < ActiveRecord::Migration[7.1]
  def change
    add_column :attendances, :note, :text
  end
end
