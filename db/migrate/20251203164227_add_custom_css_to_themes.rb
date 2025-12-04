class AddCustomCssToThemes < ActiveRecord::Migration[7.1]
  def change
    add_column :themes, :custom_css, :text
  end
end
