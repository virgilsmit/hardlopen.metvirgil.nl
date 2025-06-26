class TrainingSession < ApplicationRecord
  belongs_to :training_schema
  belongs_to :group, optional: true
  belongs_to :user, optional: true
  belongs_to :trainer, class_name: 'User', foreign_key: 'trainer_id', optional: true
  has_many :attendances, dependent: :destroy

  validates :date, presence: true
  validates :training_schema_id, presence: true

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
end
