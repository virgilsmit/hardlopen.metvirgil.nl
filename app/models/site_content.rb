class SiteContent < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  
  # Helper method om content op te halen met fallback
  def self.get(key, default = nil)
    find_by(key: key)&.value || default
  end
  
  # Helper method om content op te slaan
  def self.set(key, value)
    content = find_or_initialize_by(key: key)
    content.value = value
    content.save
    content
  end
end
