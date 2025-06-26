class Training < ApplicationRecord
  has_many :attendances, dependent: :destroy
  has_many :users, through: :attendances
  belongs_to :user, optional: true  # user == nil betekent: groepssessie
  has_many :training_assignments
  has_many :trainers, through: :training_assignments, source: :user

  validates :title, :date, presence: true
end
