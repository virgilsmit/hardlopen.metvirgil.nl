class TrainingRoute < ApplicationRecord
  belongs_to :training_session # Changed from :training
  belongs_to :route
end
