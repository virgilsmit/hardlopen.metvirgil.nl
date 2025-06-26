class UpdateUsersTable < ActiveRecord::Migration[7.1]
  def change
    # Add password_digest if it doesn't exist
    unless column_exists?(:users, :password_digest)
      add_column :users, :password_digest, :string
    end

    # Handle the 'role' column: change from string to integer, map values, set default and NOT NULL.
    if column_exists?(:users, :role)
      role_column = ActiveRecord::Base.connection.columns(:users).find { |c| c.name == 'role' }

      if role_column&.type == :string
        # Step 1: Change type using raw SQL for the USING clause for robust conversion
        execute <<-SQL
          ALTER TABLE users
          ALTER COLUMN role TYPE integer
          USING (
            CASE role
              WHEN 'user' THEN 0
              WHEN 'trainer' THEN 1
              WHEN 'admin' THEN 2
              ELSE 0 -- Default for any other existing string values or if new records are made before default is set
            END
          );
        SQL
        # Step 2: Set the default value for new records
        change_column_default :users, :role, 0
        # Step 3: Enforce NOT NULL constraint
        change_column_null :users, :role, false
      elsif role_column&.type == :integer
        # If already integer, ensure default and null constraints are correctly set
        current_default = role_column.default # Corrected: Get default from column object
        change_column_default :users, :role, 0 if current_default.nil? || current_default != "0"

        is_nullable = role_column.null
        change_column_null :users, :role, false if is_nullable
      else
        # If column exists but is neither string nor integer, this is an unexpected state.
        # For safety, we could log a warning or raise an error.
        # Or, attempt to add it if it somehow got removed by a previous failed migration attempt.
        unless column_exists?(:users, :role, :integer)
          add_column :users, :role, :integer, default: 0, null: false
        end
      end
    else
      # If role column doesn't exist at all, add it as integer with default and null constraints
      add_column :users, :role, :integer, default: 0, null: false
    end

    # Remove old Devise columns if they exist
    remove_column :users, :encrypted_password, :string if column_exists?(:users, :encrypted_password)
    remove_column :users, :reset_password_token, :string if column_exists?(:users, :reset_password_token)
    remove_column :users, :reset_password_sent_at, :datetime if column_exists?(:users, :reset_password_sent_at)
    remove_column :users, :remember_created_at, :datetime if column_exists?(:users, :remember_created_at)

    # Ensure email column has the right properties (not null, default empty string, unique index)
    if column_exists?(:users, :email)
      email_column = ActiveRecord::Base.connection.columns(:users).find { |c| c.name == 'email' } # Get column object

      change_column_null :users, :email, false unless !email_column&.null # Check null from column object
      # Corrected: Get default from column object and compare
      change_column_default :users, :email, "" if email_column && email_column.default != ""
      unless index_exists?(:users, :email, unique: true)
        # Remove non-unique index if it exists to avoid conflict
        remove_index :users, :email if index_exists?(:users, :email)
        add_index :users, :email, unique: true
      end
    else
      # If email column doesn't exist, add it with all constraints
      add_column :users, :email, :string, null: false, default: ""
      add_index :users, :email, unique: true
    end

    # Add index for role if it doesn't exist
    unless index_exists?(:users, :role)
      add_index :users, :role
    end
  end
end
