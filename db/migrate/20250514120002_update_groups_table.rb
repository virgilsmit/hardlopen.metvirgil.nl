class UpdateGroupsTable < ActiveRecord::Migration[7.1]
  def change
    # Add trainer_id column, referencing users table
    add_reference :groups, :trainer, foreign_key: { to_table: :users }

    # Remove old 'trainer' (string) column if it exists and is of type string.
    # This replaces the previous complex conditional block.
    if ActiveRecord::Base.connection.column_exists?(:groups, :trainer)
      # Verify that the column named 'trainer' is indeed the old string type column
      # before removing it. add_reference should have created 'trainer_id'.
      column_definition = ActiveRecord::Base.connection.columns(:groups).find { |c| c.name == 'trainer' }
      if column_definition && column_definition.type == :string
        # Data migration from old string 'trainer' to new 'trainer_id' (User reference)
        # would ideally go here. This requires the Group and User models.
        Group.reset_column_information
        User.reset_column_information
        Group.find_each do |group|
          old_trainer_value = group.attributes_before_type_cast['trainer']
          if old_trainer_value.present?
            trainer_user = User.find_by(email: old_trainer_value) || User.find_by(name: old_trainer_value)
            if trainer_user
              group.update_column(:trainer_id, trainer_user.id) # Use update_column to skip validations/callbacks
            else
              # Set trainer_id to NULL if no matching user is found
              group.update_column(:trainer_id, nil)
              Rails.logger.warn "WARN: Could not find User for trainer value: #{old_trainer_value} for group #{group.id} during migration. Setting trainer_id to NULL."
            end
          end
        end
        remove_column :groups, :trainer, :string
      end
    end

    # Add training_days as a string array (for PostgreSQL)
    # t.string :training_days, array: true, default: []
  end
end
