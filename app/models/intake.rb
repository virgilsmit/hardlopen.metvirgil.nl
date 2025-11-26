class Intake < ApplicationRecord
  enum gender: { man: 'man', vrouw: 'vrouw', neutraal: 'neutraal', geen_antwoord: 'geen_antwoord' }

  belongs_to :created_user, class_name: 'User', optional: true
  belongs_to :processed_by, class_name: 'User', optional: true

  validates :first_name, :last_name, :email, :birthdate, :gender, :emergency_number, :shirt_size, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cooper_test_meters, numericality: { only_integer: true, greater_than: 0 }, allow_blank: true

  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }

  def full_name
    [first_name, last_name].compact_blank.join(' ')
  end

  def processed?
    processed_at.present?
  end
end

