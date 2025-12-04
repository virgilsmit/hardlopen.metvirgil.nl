class AddUserFriendlyDescriptionToErrorLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :error_logs, :user_friendly_description, :text
  end
end
