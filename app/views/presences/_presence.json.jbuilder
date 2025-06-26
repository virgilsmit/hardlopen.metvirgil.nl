json.extract! presence, :id, :session_id, :name, :user_id, :status, :created_at, :updated_at
json.url presence_url(presence, format: :json)
