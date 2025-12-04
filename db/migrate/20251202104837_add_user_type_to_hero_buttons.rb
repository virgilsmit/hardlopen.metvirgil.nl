class AddUserTypeToHeroButtons < ActiveRecord::Migration[7.1]
  def change
    add_column :hero_buttons, :user_type, :string, default: 'guest'
    add_index :hero_buttons, :user_type
  end
end
