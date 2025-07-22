class TrainingSession < ApplicationRecord
  belongs_to :training_schema
  belongs_to :group, optional: true
  belongs_to :user, optional: true
  belongs_to :trainer, class_name: 'User', foreign_key: 'trainer_id', optional: true
  has_many :attendances, dependent: :destroy
  has_many :training_results, dependent: :destroy

  validates :date, presence: true
  validates :training_schema_id, presence: true

  before_save :populate_structured_core, if: -> { will_save_change_to_description? }

  def kern
    weekday = date.strftime('%A') rescue nil
    if weekday == 'Tuesday' || weekday == 'Dinsdag'
      training_schema&.dinsdag_interval.presence || '-'
    elsif weekday == 'Saturday' || weekday == 'Zaterdag'
      training_schema&.zaterdag_duurloop.presence || '-'
    else
      '-'
    end
  end

  def locatie
    location.presence || training_schema&.location.presence || 'GAC Clubhuis'
  end

  private
  def populate_structured_core
    text = self.respond_to?(:core) ? (self.core || '') : (self.description || '')
    self.structured_core = CoreParserService.new(text).call
  end
end
