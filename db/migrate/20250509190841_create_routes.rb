class CreateRoutes < ActiveRecord::Migration[7.1]
  def change
    create_table :routes do |t|
      t.string :name
      t.float :distance
      t.text :description

      t.timestamps
    end
  end
end
