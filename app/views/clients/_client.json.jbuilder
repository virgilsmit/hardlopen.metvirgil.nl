json.extract! client, :id, :user_id, :group_id, :created_at, :updated_at
json.url client_url(client, format: :json)
