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
        all_upcoming = schema.training_sessions.where('date >= ?', Date.today).order(:date)
        # Alle verleden trainingen
        all_past = schema.training_sessions.where('date < ?', Date.today).order(date: :desc)
        
        # Filter op actieve trainingsdagen als de gebruiker die heeft ingesteld
        if current_user&.training_days.present?
          @upcoming_sessions = all_upcoming.select do |session|
            # Gebruik de dag kolom uit de database (lowercase) en vergelijk met training_days (capitalized)
            day_name = session.dag.to_s.capitalize
            current_user.training_days.include?(day_name)
          end
          @past_sessions = all_past.select do |session|
            day_name = session.dag.to_s.capitalize
            current_user.training_days.include?(day_name)
          end
        else
          @upcoming_sessions = all_upcoming
          @past_sessions = all_past
        end
        
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
  
  def update
    @training_schema = TrainingSchema.find(params[:id])
    
    respond_to do |format|
      if @training_schema.update(training_schema_params)
        format.json { render json: { success: true, schema: @training_schema }, status: :ok }
        format.html { redirect_to schema_path, notice: 'Schema bijgewerkt.' }
      else
        format.json { render json: { success: false, errors: @training_schema.errors }, status: :unprocessable_entity }
        format.html { redirect_to schema_path, alert: 'Bijwerken mislukt.' }
      end
    end
  end

  def all
    if current_user&.default_training_schema.present?
      schema = current_user.default_training_schema
      all_upcoming = schema.training_sessions.where('date >= ?', Date.today).order(:date)
      all_past = schema.training_sessions.where('date < ?', Date.today).order(date: :desc)
      
      # Filter op trainingsdagen van de gebruiker
      if current_user.training_days.present?
        @upcoming_sessions = all_upcoming.select do |session|
          day_name = (session.dag || I18n.l(session.date, format: '%A', locale: :nl)).capitalize
          current_user.training_days.include?(day_name)
        end
        
        @past_sessions = all_past.select do |session|
          day_name = (session.dag || I18n.l(session.date, format: '%A', locale: :nl)).capitalize
          current_user.training_days.include?(day_name)
        end
      else
        @upcoming_sessions = all_upcoming
        @past_sessions = all_past
      end
      
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
      
      # Haal alle trainingen van HET SCHEMA van de gebruiker voor deze week
      all_sessions = schema.training_sessions
                           .includes(:attendances, :trainer)
                           .where(date: Date.today.beginning_of_week..Date.today.end_of_week)
                           .order(:date)
      
      # Filter op trainingsdagen van de gebruiker
      if current_user.training_days.present?
        @week_sessions = all_sessions.select do |session|
          # Gebruik de dag kolom uit de database (in Nederlands) en capitalize voor matching
          day_name = (session.dag || I18n.l(session.date, format: '%A', locale: :nl)).capitalize
          current_user.training_days.include?(day_name)
        end
      else
        @week_sessions = all_sessions
      end
      
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
