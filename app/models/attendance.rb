class Attendance < ApplicationRecord
  belongs_to :user
  belongs_to :training_session

  enum status: { aanwezig: 0, afwezig: 1, onbekend: 2 } # onbekend als default

  validates :user_id, presence: true
  validates :training_session_id, presence: true
  validates :status, presence: true, inclusion: { in: %w[aanwezig afwezig onbekend] }
  
  # Note is verplicht bij afwezig, tenzij het "Afgemeld door trainer" is
  validates :note, presence: { message: "kan niet leeg zijn" }, if: -> { 
    status.to_s == 'afwezig' && (note.blank? || (note.present? && note.strip != 'Afgemeld door trainer'))
  }

  # Zorgt ervoor dat een gebruiker maar één attendance record per training sessie kan hebben
  validates :user_id, uniqueness: { scope: :training_session_id }
  
  # Automatisch "Afgemeld door trainer" toevoegen als note leeg is bij afwezig
  before_validation :set_default_note, if: -> { status.to_s == 'afwezig' && note.blank? }
  
  private
  
  def set_default_note
    self.note = 'Afgemeld door trainer'
  end
end
