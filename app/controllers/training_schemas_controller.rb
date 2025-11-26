class TrainingSchemasController < ApplicationController
  def index
    @schemas = TrainingSchema.all.to_a
    if current_user&.default_training_schema
      @upcoming_sessions = current_user.default_training_schema.training_sessions.where('date >= ?', Date.today).order(:date)
      @schema_name = current_user.default_training_schema.name
    else
      @upcoming_sessions = []
      @schema_name = nil
    end
  end

  def show
    require 'date'
    
    # Als er een id parameter is, gebruik die. Anders gebruik het standaard schema van de gebruiker als die er is.
    schema_id = params[:id] || (current_user&.default_training_schema&.id)
    
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
    
    # Als er een specifiek schema_id is, toon alleen dat schema
    if schema_id.present?
      schema = TrainingSchema.find_by(id: schema_id)
      if schema
        # Alle komende trainingen
        @upcoming_sessions = schema.training_sessions.where('date >= ?', Date.today).order(:date)
        # Alle verleden trainingen
        @past_sessions = schema.training_sessions.where('date < ?', Date.today).order(date: :desc)
        # Voor backwards compatibility: week overzicht
        filtered_sessions = schema.training_sessions.select { |sessie| sessie.date && sessie.date.cweek == week && sessie.date.cwyear == jaar }
        @schemas = [OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)]
        @trainings_this_week = schema.training_sessions.where(week: week.to_s).order(:date)
      else
        @schemas = []
        @trainings_this_week = []
        @upcoming_sessions = []
        @past_sessions = []
      end
    elsif current_user.admin? || current_user.trainer?
      # Voor admins/trainers: toon alle schema's
      all_schemas = TrainingSchema.all
      @upcoming_sessions = TrainingSession.where('date >= ?', Date.today).order(:date)
      @past_sessions = TrainingSession.where('date < ?', Date.today).order(date: :desc)
      # Voor backwards compatibility
      @schemas = all_schemas.map do |schema|
        filtered_sessions = schema.training_sessions.select { |sessie| sessie.date && sessie.date.cweek == week && sessie.date.cwyear == jaar }
        OpenStruct.new(id: schema.id, name: schema.name, description: schema.description, training_sessions: filtered_sessions)
      end
      @trainings_this_week = TrainingSession.where(week: week.to_s).order(:date)
    else
      # Voor gewone gebruikers zonder schema: geen trainingen
      @schemas = []
      @trainings_this_week = []
      @upcoming_sessions = []
      @past_sessions = []
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
    if current_user&.default_training_schema.present?
      schema = current_user.default_training_schema
      @upcoming_sessions = schema.training_sessions.where('date >= ?', Date.today).order(:date)
      @past_sessions = schema.training_sessions.where('date < ?', Date.today).order(date: :desc)
      @schema_name = schema.name
    else
      @upcoming_sessions = []
      @past_sessions = []
      @schema_name = nil
    end
  end

  def dezeweek
    week = Date.today.cweek
    year = Date.today.cwyear

    if current_user&.default_training_schema.present?
      schema = current_user.default_training_schema
      @week_sessions = schema.training_sessions.includes(:attendances, :trainer).where(date: Date.today.beginning_of_week..Date.today.end_of_week).order(:date)
      @schema_name = schema.name
    else
      @week_sessions = []
      @schema_name = nil
    end
  end

  private

  def training_schema_params
    params.require(:training_schema).permit(:name, :description, :group_id)
  end
end
