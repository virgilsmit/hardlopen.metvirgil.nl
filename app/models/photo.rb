class Photo < ApplicationRecord
  belongs_to :user
  belongs_to :training_session # Changed from :training
end
