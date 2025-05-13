json.extract! user, :id, :name, :email, :phone, :emergency_contact, :birthday, :injury, :photo_permission, :created_at, :updated_at
json.url user_url(user, format: :json)
