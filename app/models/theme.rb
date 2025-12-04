class Theme < ApplicationRecord
  validates :name, presence: true
  validates :primary_color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "moet een hex kleur zijn (bijv. #FC4C02)" }
  validates :secondary_color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "moet een hex kleur zijn" }
  
  # Zorg dat er altijd maar één actief thema is
  before_save :ensure_single_active_theme, if: :active?
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  def self.current
    active.first || first || create_default_theme
  end
  
  def self.create_default_theme
    create!(
      name: 'Default Theme',
      active: true,
      primary_color: '#FC4C02',
      secondary_color: '#00B4DB',
      accent_color: '#FFD23F',
      success_color: '#28A745',
      warning_color: '#FFC107',
      danger_color: '#DC3545',
      background_color: '#FFFFFF',
      background_color_alt: '#F8F9FA',
      header_background: '#0a152b',
      card_background: '#FFFFFF',
      card_background_dark: '#1E1E1E',
      text_color_light: '#0c1729',
      text_color_dark: '#f4f8ff',
      text_color_muted: '#6C757D',
      text_color_muted_dark: '#B0B0B0',
      border_color: '#E9ECEF',
      border_color_dark: '#2D2D2D',
      font_family: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
      font_family_secondary: 'Roboto, -apple-system, BlinkMacSystemFont, "Segoe UI", "Helvetica Neue", Arial, sans-serif',
      font_size_base: '1rem',
      font_weight_normal: '400',
      font_weight_semibold: '600',
      font_weight_bold: '700',
      spacing_unit: '0.5rem',
      border_radius_small: '8px',
      border_radius_medium: '12px',
      border_radius_large: '20px',
      shadow_small: '0 2px 8px rgba(0, 0, 0, 0.1)',
      shadow_medium: '0 4px 20px rgba(0, 0, 0, 0.15)',
      shadow_large: '0 8px 32px rgba(0, 0, 0, 0.2)'
    )
  end
  
  private
  
  def ensure_single_active_theme
    Theme.where.not(id: id).update_all(active: false) if active?
  end
end
