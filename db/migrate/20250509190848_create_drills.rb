class CreateDrills < ActiveRecord::Migration[7.1]
  def change
    create_table :drills do |t|
      t.string :name
      t.text :description
      t.string :video_url

      t.timestamps
    end
  end
end
