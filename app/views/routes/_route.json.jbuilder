json.extract! route, :id, :name, :distance, :description, :created_at, :updated_at
json.url route_url(route, format: :json)
