class CreateGroupMemberships < ActiveRecord::Migration[7.1]
  def change
    create_table :group_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    # Add a unique index on user_id and group_id to ensure a user can only join a group once.
    add_index :group_memberships, [:user_id, :group_id], unique: true
  end
end
