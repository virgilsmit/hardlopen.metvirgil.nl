json.extract! attendance, :id, :user_id, :training_id, :status, :created_at, :updated_at
json.url attendance_url(attendance, format: :json)
