json.extract! training_drill, :id, :training_session_id, :drill_id, :created_at, :updated_at # Changed training_id to training_session_id
json.url training_drill_url(training_drill, format: :json)
