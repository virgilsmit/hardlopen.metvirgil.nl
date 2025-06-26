class User < ApplicationRecord
  has_secure_password

  enum role: { user: 0, trainer: 1, admin: 2 }

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # Relationships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships # Groups a user is a member of

  # If a user is a trainer for groups
  has_many :coached_groups, class_name: 'Group', foreign_key: 'trainer_id', dependent: :nullify

  has_many :individual_training_schemas, class_name: 'TrainingSchema', foreign_key: 'user_id', dependent: :destroy
  has_many :training_sessions, dependent: :destroy # For individual training sessions created by/for the user
  
  has_many :attendances, dependent: :destroy
  has_many :trainings, through: :attendances

  has_many :training_assignments
  has_many :trainingen, through: :training_assignments, source: :training

  has_many :performances, dependent: :destroy

  has_many :hoofdtrainer_groepen, class_name: 'Group', foreign_key: 'hoofdtrainer_id', dependent: :nullify
  has_many :medetrainer_groepen, class_name: 'Group', foreign_key: 'medetrainer_id', dependent: :nullify

  belongs_to :status, optional: true

  # Helper methods
  def member_of?(group)
    groups.include?(group)
  end

  def coaches_group?(group)
    coached_groups.include?(group)
  end
end
