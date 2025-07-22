class AddPublicTokenAndSlugToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :public_token, :string
    add_index :users, :public_token, unique: true
    add_column :users, :slug, :string
    add_index :users, :slug
  end
end 