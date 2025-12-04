class CreateLoginLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :login_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent
      t.datetime :logged_in_at

      t.timestamps
    end
  end
end
