class CreateSiteContents < ActiveRecord::Migration[7.1]
  def change
    create_table :site_contents do |t|
      t.string :key, null: false
      t.text :value

      t.timestamps
    end
    
    add_index :site_contents, :key, unique: true
  end
end
