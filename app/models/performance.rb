class Performance < ApplicationRecord
  belongs_to :user

  before_save :normalize_time_format
  after_save :clear_runner_threshold_cache

  # Bereken geschatte AD hartslag op basis van gemiddelde hartslag kern
  # AD is typisch ~95% van de gemiddelde hartslag tijdens intensieve kern
  def calculated_ad_heart_rate
    return nil unless core_heart_rate.present? && core_heart_rate > 0
    (core_heart_rate * 0.95).round
  end

  private

  # Normaliseer tijd formaat: vervang punten door dubbele punten
  # Zodat "00.31.01" wordt "00:31:01"
  def normalize_time_format
    if value.present? && value.include?('.')
      self.value = value.gsub('.', ':')
      Rails.logger.info "Performance #{id}: Normalized time format from #{value_was} to #{value}"
    end
  end

  def clear_runner_threshold_cache
    # Veilig de user ophalen en cache clearen
    begin
      u = User.find_by(id: user_id)
      u&.clear_threshold_cache! if u&.respond_to?(:clear_threshold_cache!)
    rescue => e
      Rails.logger.error "Error clearing threshold cache: #{e.message}"
    end
  end
end
