class Group < ApplicationRecord
  # Relationships
  belongs_to :hoofdtrainer, class_name: 'User', optional: true
  belongs_to :medetrainer, class_name: 'User', optional: true
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :training_schemas # Schemas specifically for this group
  has_many :training_sessions, dependent: :destroy # Trainings specifically for this group

  # Validations
  validates :name, presence: true, uniqueness: true
  # training_days could be an array of strings e.g., ['Monday', 'Wednesday', 'Friday']
  # For PostgreSQL, you can use an array column. If you add this column, uncomment validation.
  # validates :training_days, presence: true # Assuming this is required

  def add_member(user)
    users << user unless users.include?(user)
  end

  def remove_member(user)
    users.delete(user)
  end
end
