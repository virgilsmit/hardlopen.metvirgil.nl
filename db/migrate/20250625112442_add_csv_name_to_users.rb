class AddCsvNameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :csv_name, :string
  end
end
