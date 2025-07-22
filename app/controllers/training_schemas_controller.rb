class TrainingSchemasController < ApplicationController
  def index
    @schemas = TrainingSchema.all.to_a
    @upcoming_sessions = TrainingSession.where('date >= ?', Date.today).order(:date)
  end

  def show
    require 'date'
    if params[:week].present? && params[:week] != 'current'
      if params[:week] =~ /^\d{4}-\d{2}$/ # ISO week, bv. 2025-27
        jaar, week = params[:week].split('-').map(&:to_i)
      else
        ref_date = Date.parse(params[:week]) rescue Date.today
        jaar = ref_date.cwyear
        week = ref_date.cweek
      end
    else
      ref_date = Date.today
      jaar = ref_date.cwyear
      week = ref_date.cweek
    end
    @weeknummer = week
    @weekjaar = jaar
    # Debug: lijst van alle weken als string
    alle_sessions = TrainingSession.all
    @beschikbare_weken = alle_sessions.group_by { |s| [s.date.cwyear.to_i, s.week.to_i] }.map { |(jaar, week), sessies| { jaar: jaar, week: week, eerste_datum: sessies.map(&:date).min } }.sort_by { |h| [h[:jaar], h[:week]] }
    today = Date.today
    current_week = today.cweek
    current_year = today.cwyear
    @all_sessions = TrainingSession.where('date >= ?', Date.today).order(:date)
    if current_user.admin? || current_user.trainer?
      @schemas = TrainingSchema.includes(:training_sessions).map do |schema|
        filtered_sessions = schema.training_sessions.select { |sessie| sessie.date && sessie.date.cweek == week && sessie.date.cwyear == jaar }
        OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)
      end
      @trainings_this_week = TrainingSession.where(week: week.to_s).order(:date)
    else
      user_group_ids = current_user.groups.pluck(:id)
      @schemas = TrainingSchema.includes(:training_sessions).where("group_id IN (?) OR user_id = ?", user_group_ids, current_user.id).map do |schema|
        filtered_sessions = schema.training_sessions.select { |sessie| sessie.date && sessie.date.cweek == week && sessie.date.cwyear == jaar }
        OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)
      end
      @trainings_this_week = TrainingSession.where(week: week.to_s).where("group_id IN (?) OR user_id = ?", user_group_ids, current_user.id).order(:date)
    end
  end

  def create
    @training_schema = TrainingSchema.new(training_schema_params)
    if @training_schema.save
      redirect_to schema_path, notice: 'Trainingsschema succesvol aangemaakt.'
    else
      @groups = Group.all
      render 'admin/dashboard/training_schema_form', status: :unprocessable_entity, locals: { training_schema: @training_schema, groups: @groups }
    end
  end

  def all
    @upcoming_sessions = TrainingSession.where('date >= ?', Date.today).order(:date)
    @past_sessions = TrainingSession.where('date < ?', Date.today).order(date: :desc)
  end

  def dezeweek
    week = Date.today.cweek
    year = Date.today.cwyear
    @week_sessions = TrainingSession.includes(:attendances, :trainer).where(week: week, date: Date.today.beginning_of_week..Date.today.end_of_week).order(:date)
  end

  private

  def training_schema_params
    params.require(:training_schema).permit(:name, :description, :group_id)
  end
end
