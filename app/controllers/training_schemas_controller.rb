class TrainingSchemasController < ApplicationController
  def index
    @schemas = TrainingSchema.all.to_a
  end

  def show
    if params[:week] == 'current'
      reference_date = Date.today
      start_week = reference_date.beginning_of_week(:monday)
      end_week = start_week + 6.days
      if current_user.admin? || current_user.trainer?
        # Trainers en admins zien alle schemas en sessies van deze week
        @schemas = TrainingSchema.includes(:training_sessions).map do |schema|
          filtered_sessions = schema.training_sessions.where(date: start_week..end_week)
          OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)
        end
      else
        # Lopers zien alleen hun eigen/groepsschemas en sessies van deze week
        user_group_ids = current_user.groups.pluck(:id)
        @schemas = TrainingSchema.includes(:training_sessions).where("group_id IN (?) OR user_id = ?", user_group_ids, current_user.id).map do |schema|
          filtered_sessions = schema.training_sessions.where(date: start_week..end_week)
          OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)
        end
      end
    else
      @schemas = TrainingSchema.includes(:training_sessions).all
    end
  end
end
