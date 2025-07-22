class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :training_session

  enum status: { aanwezig: 0, afwezig: 1, onbekend: 2 } # onbekend als default

  validates :user_id, presence: true
  validates :training_session_id, presence: true
  validates :status, presence: true, inclusion: { in: ["aanwezig", "afwezig", "onbekend"] }

  # Zorgt ervoor dat een gebruiker maar één attendance record per training sessie kan hebben
  validates :user_id, uniqueness: { scope: :training_session_id }
end
