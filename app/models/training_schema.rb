class TrainingSchema < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :user, optional: true
  has_many :training_sessions, dependent: :destroy

  validates :name, presence: true

  after_initialize :set_default_location, if: :new_record?

  def dinsdag_interval
    # Hier kun je later dynamisch maken of uit de database halen
    '8x 400m uit schema'  # testwaarde
  end

  def zaterdag_duurloop
    '10km rustig tempo uit schema'  # testwaarde
  end

  def set_default_location
    self.location ||= 'GAC Clubhuis'
  end
end
