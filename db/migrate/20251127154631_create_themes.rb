class CreateThemes < ActiveRecord::Migration[7.1]
  def change
    create_table :themes do |t|
      t.string :name, null: false, default: 'Default Theme'
      t.boolean :active, default: false
      
      # Kleuren
      t.string :primary_color, default: '#FC4C02'
      t.string :secondary_color, default: '#00B4DB'
      t.string :accent_color, default: '#FFD23F'
      t.string :success_color, default: '#28A745'
      t.string :warning_color, default: '#FFC107'
      t.string :danger_color, default: '#DC3545'
      
      # Achtergronden
      t.string :background_color, default: '#FFFFFF'
      t.string :background_color_alt, default: '#F8F9FA'
      t.string :header_background, default: '#0a152b'
      t.string :card_background, default: '#FFFFFF'
      t.string :card_background_dark, default: '#1E1E1E'
      
      # Tekst kleuren
      t.string :text_color_light, default: '#0c1729'
      t.string :text_color_dark, default: '#f4f8ff'
      t.string :text_color_muted, default: '#6C757D'
      t.string :text_color_muted_dark, default: '#B0B0B0'
      
      # Borders
      t.string :border_color, default: '#E9ECEF'
      t.string :border_color_dark, default: '#2D2D2D'
      
      # Typography
      t.string :font_family, default: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif'
      t.string :font_family_secondary, default: 'Roboto, -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial, sans-serif'
      t.string :font_size_base, default: '1rem'
      t.string :font_weight_normal, default: '400'
      t.string :font_weight_semibold, default: '600'
      t.string :font_weight_bold, default: '700'
      
      # Spacing
      t.string :spacing_unit, default: '0.5rem'
      
      # Border radius
      t.string :border_radius_small, default: '8px'
      t.string :border_radius_medium, default: '12px'
      t.string :border_radius_large, default: '20px'
      
      # Shadows
      t.string :shadow_small, default: '0 2px 8px rgba(0, 0, 0, 0.1)'
      t.string :shadow_medium, default: '0 4px 20px rgba(0, 0, 0, 0.15)'
      t.string :shadow_large, default: '0 8px 32px rgba(0, 0, 0, 0.2)'

      t.timestamps
    end
    
    # Maak een standaard thema aan
    add_index :themes, :active
  end
end
