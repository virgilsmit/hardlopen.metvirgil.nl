class TrainingResult < ApplicationRecord
  belongs_to :user
  belongs_to :training_session

  validates :training_session_id, presence: true
  validates :user_id, presence: true
  # structured_core should be jsonb non-null but allow blank; let db enforce default

  def pace_per_km
    return nil if time.to_i.zero? || distance.to_f.zero?
    seconds = time.to_f / distance.to_f
    seconds.round
  end
end 