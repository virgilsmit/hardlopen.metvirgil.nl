json.extract! training_schedule, :id, :group_id, :weekday, :start_time, :end_time, :location, :active, :created_at, :updated_at
json.url training_schedule_url(training_schedule, format: :json)
