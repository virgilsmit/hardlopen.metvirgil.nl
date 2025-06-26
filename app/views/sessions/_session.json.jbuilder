json.extract! session, :id, :group_id, :title, :description, :start_time, :end_time, :trainer_name, :created_at, :updated_at
json.url session_url(session, format: :json)
