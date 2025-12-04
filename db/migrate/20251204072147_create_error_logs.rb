class CreateErrorLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :error_logs do |t|
      t.string :code, null: false
      t.string :error_class
      t.text :error_message
      t.text :backtrace
      t.string :url
      t.string :request_method
      t.integer :user_id
      t.string :ip_address
      t.text :user_agent
      t.text :params
      t.text :session_data
      t.boolean :resolved, default: false
      t.datetime :resolved_at
      t.integer :resolved_by
      t.text :notes

      t.timestamps
    end
    
    add_index :error_logs, :code, unique: true
    add_index :error_logs, :error_class
    add_index :error_logs, :resolved
    add_index :error_logs, :created_at
    add_index :error_logs, :user_id
  end
end
