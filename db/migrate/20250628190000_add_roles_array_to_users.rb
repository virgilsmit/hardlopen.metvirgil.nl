class AddRolesArrayToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :roles, :string, array: true, default: ['user']
  end
end 