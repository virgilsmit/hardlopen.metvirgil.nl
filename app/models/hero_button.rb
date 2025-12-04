class HeroButton < ApplicationRecord
  validates :label, presence: true
  validates :url, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :user_type, presence: true, inclusion: { in: %w[guest logged_in] }
  validates :role, inclusion: { in: %w[all user trainer admin], allow_nil: true }
  
  scope :visible, -> { where(visible: true).order(:position) }
  scope :ordered, -> { order(:position) }
  scope :for_guests, -> { where(user_type: 'guest') }
  scope :for_logged_in, -> { where(user_type: 'logged_in') }
  
  # Hiërarchische rol filtering: admin ziet alles, trainer ziet trainer+user, user ziet alleen user
  scope :for_role, ->(user_role) {
    case user_role
    when 'admin'
      # Admin ziet alles
      all
    when 'trainer'
      # Trainer ziet: all, user, trainer
      where('role IN (?) OR role IS NULL', ['all', 'user', 'trainer'])
    when 'user'
      # User ziet: all, user
      where('role IN (?) OR role IS NULL', ['all', 'user'])
    else
      # Fallback: alleen 'all'
      where('role = ? OR role IS NULL', 'all')
    end
  }
  
  # Available button styles
  STYLES = {
    'primary' => 'sport-btn--primary',
    'secondary' => 'sport-btn--secondary',
    'ghost' => 'sport-btn--ghost'
  }.freeze
  
  USER_TYPES = {
    'guest' => 'Niet-ingelogde gebruikers',
    'logged_in' => 'Ingelogde gebruikers'
  }.freeze
  
  ROLES = {
    'all' => 'Alle gebruikers',
    'user' => 'Alleen lopers',
    'trainer' => 'Alleen trainers',
    'admin' => 'Alleen admins'
  }.freeze
  
  def style_class
    STYLES[style] || STYLES['primary']
  end
  
  def user_type_label
    USER_TYPES[user_type] || user_type
  end
  
  def role_label
    ROLES[role] || role || 'Alle gebruikers'
  end
end
