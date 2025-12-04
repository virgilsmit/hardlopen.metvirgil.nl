class CreateHeroButtons < ActiveRecord::Migration[7.1]
  def change
    create_table :hero_buttons do |t|
      t.string :label
      t.string :url
      t.string :icon
      t.string :style
      t.integer :position
      t.boolean :visible, default: true
      t.string :description

      t.timestamps
    end
    
    add_index :hero_buttons, :position
  end
end
