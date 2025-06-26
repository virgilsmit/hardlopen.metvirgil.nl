json.extract! training_route, :id, :training_session_id, :route_id, :created_at, :updated_at # Changed training_id to training_session_id
json.url training_route_url(training_route, format: :json)
