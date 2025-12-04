class AddRoleToHeroButtons < ActiveRecord::Migration[7.1]
  def change
    add_column :hero_buttons, :role, :string, default: 'all'
    add_index :hero_buttons, :role
  end
end
