class TrainingDrill < ApplicationRecord
  belongs_to :training_session # Changed from :training
  belongs_to :drill
end
