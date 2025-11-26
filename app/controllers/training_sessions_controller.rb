class TrainingSessionsController < ApplicationController
  def show
    @training_session = TrainingSession.find(params[:id])
  end

  def vandaag
    @training_session = TrainingSession.where(date: Date.today).first
    if @training_session.nil?
      redirect_to root_path, alert: 'Geen training voor vandaag gevonden.'
    end
  end

  def edit
    @training_session = TrainingSession.find(params[:id])
    unless current_user.admin? || (current_user.has_role?(:trainer) && (@training_session.group&.hoofdtrainer_id == current_user.id || @training_session.group&.medetrainer_id == current_user.id || current_user.has_role?(:trainer)))
      redirect_to training_session_path(@training_session), alert: 'Geen toegang.'
    end
  end

  def update
    @training_session = TrainingSession.find(params[:id])
    unless current_user.admin? || (current_user.has_role?(:trainer) && (@training_session.group&.hoofdtrainer_id == current_user.id || @training_session.group&.medetrainer_id == current_user.id || current_user.has_role?(:trainer)))
      redirect_to training_session_path(@training_session), alert: 'Geen toegang.' and return
    end
    
    # Als het alleen om trainer_id gaat, sta alle trainers toe
    if params[:training_session]&.keys == ['trainer_id'] && current_user.has_role?(:trainer)
      if @training_session.update(trainer_id: params[:training_session][:trainer_id])
        redirect_to training_session_path(@training_session), notice: 'Trainer bijgewerkt.'
      else
        render :edit, status: :unprocessable_entity
      end
      return
    end
    
    # Voor andere velden, gebruik de originele autorisatie
    if @training_session.update(training_session_params)
      redirect_to training_session_path(@training_session), notice: 'Training bijgewerkt.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_core
    @training_session = TrainingSession.find(params[:id])
    authorize_edit!
    new_core = JSON.parse(params[:structured_core] || '[]') rescue []
    @training_session.update(structured_core: new_core)
    render json: {status: 'ok', structured_core: @training_session.structured_core}
  end

  def authorize_edit!
    unless current_user && (current_user.admin? || current_user.id == @training_session.user_id || current_user.has_role?(:trainer))
      render json: {error: 'not allowed'}, status: :forbidden and return
    end
  end

  def mijn
    require_user
    sessions_attended = TrainingSession.joins(:attendances).where(attendances: { user_id: current_user.id })
    week_start = Date.today.beginning_of_week(:monday)
    week_end   = week_start + 6.days

    # Training van vandaag (ongeacht attendance)
    @today_session = TrainingSession.find_by(date: Date.today)

    # Alle sessies deze week, ook als user niet is aangemeld
    @week_sessions = TrainingSession.where(date: week_start..week_end).order(date: :asc)

    # Historie toont alleen sessies waar gebruiker bij betrokken was
    @historical_sessions = sessions_attended.where('date < ?', week_start).order(date: :desc)
    @logged_results = current_user.training_results.includes(:training_session).order(created_at: :desc)
    @pace_zone1 = current_user.tempo_extensief
    @warmup_distance = 1.5
    @warmup_time = current_user.tijd_voor_afstand(@warmup_distance, @pace_zone1)
    @cooldown_distance = 1.5
    @cooldown_time = current_user.tijd_voor_afstand(@cooldown_distance, @pace_zone1)
  end

  def preview_structured_core
    @training_session = TrainingSession.find(params[:id])
    parser = CoreParserService.new(@training_session.description.to_s)
    @structured_preview = parser.call
  end

  def preview_cores
    week_start = Date.today.beginning_of_week(:monday)
    week_end   = week_start + 6.days
    @sessions = TrainingSession.where(date: week_start..week_end).order(:date)
    @parsed_sessions = @sessions.map do |session|
      original_text = session.respond_to?(:core) ? (session.core || '') : (session.description || '')
      parsed = CoreParserService.new(original_text).call
      ok = parsed.is_a?(Array) && parsed.any? && parsed.all? { |h| h[:duur].present? }
      {
        session: session,
        original_core: original_text,
        parsed_core: parsed,
        status: ok ? '✅' : '❌'
      }
    end
  end

  def preview_upcoming_cores
    start_date = Date.today + 1
    end_date = start_date + 3.weeks
    @sessions = TrainingSession.where(date: start_date..end_date).order(:date)
    @parsed_sessions = @sessions.map do |session|
      original_text = session.respond_to?(:core) ? (session.core || '') : (session.description || '')
      parsed = CoreParserService.new(original_text).call
      ok = parsed.is_a?(Array) && parsed.any? && parsed.all? { |h| h[:duur].present? }
      {
        session: session,
        original_core: original_text,
        parsed_core: parsed,
        status: ok ? '✅' : '❌'
      }
    end
  end

  def preview_all_cores
    start_date = Date.today
    end_date   = Date.today.end_of_year
    @sessions = TrainingSession.where(date: start_date..end_date).order(:date)
    @parsed_sessions = @sessions.map do |session|
      original = session.respond_to?(:core) ? (session.core || '') : (session.description || '')
      parsed   = CoreParserService.new(original).call
      ok = parsed.is_a?(Array) && parsed.any? && parsed.all? { |h| h[:duur].present? }
      {
        session: session,
        original_core: original,
        parsed_core: parsed,
        status: ok ? '✅' : '❌'
      }
    end
  end

  def data
    require_user
    ts = TrainingSession.find(params[:id])
    render json: {
      id: ts.id,
      date: ts.date,
      description: ts.description,
      dag: ts.dag,
      tempozones: {
        extensief: current_user.tempo_extensief,
        intensief: current_user.tempo_intensief,
        interval: current_user.tempo_interval,
        sprint: current_user.tempo_sprint
      },
      human_core: view_context.human_core(ts.structured_core, current_user),
      structured_core: ts.structured_core
    }
  end

  # API endpoints for iOS app
  def api_today
    require_user
    today_session = TrainingSession.find_by(date: Date.today)
    
    if today_session
      render json: {
        success: true,
        training: format_training_for_api(today_session)
      }
    else
      render json: {
        success: false,
        message: 'Geen training voor vandaag'
      }
    end
  end

  def api_week
    require_user
    week_start = Date.today.beginning_of_week(:monday)
    week_end = week_start + 6.days
    
    sessions = TrainingSession.where(date: week_start..week_end).order(:date)
    
    render json: {
      success: true,
      week_start: week_start,
      week_end: week_end,
      trainings: sessions.map { |session| format_training_for_api(session) }
    }
  end

  def api_upcoming
    require_user
    start_date = Date.today + 1
    end_date = start_date + 2.weeks
    
    sessions = TrainingSession.where(date: start_date..end_date).order(:date)
    
    render json: {
      success: true,
      start_date: start_date,
      end_date: end_date,
      trainings: sessions.map { |session| format_training_for_api(session) }
    }
  end

  def api_schedule
    require_user
    # Get all upcoming training sessions
    sessions = TrainingSession.where('date >= ?', Date.today).order(:date).limit(30)
    
    render json: {
      success: true,
      trainings: sessions.map { |session| format_training_for_api(session) }
    }
  end

  private

  def format_training_for_api(session)
    {
      id: session.id,
      date: session.date,
      description: session.description,
      loopscholing: session.loopscholing,
      fase: session.fase,
      wedstrijd: session.wedstrijd,
      dag: session.dag,
      location: session.locatie,
      trainer: session.trainer&.name,
      trainer_id: session.trainer_id,
      structured_core: session.structured_core,
      kern: session.kern,
      tempozones: {
        extensief: current_user.tempo_extensief,
        intensief: current_user.tempo_intensief,
        interval: current_user.tempo_interval,
        sprint: current_user.tempo_sprint
      },
      human_core: view_context.human_core(session.structured_core, current_user),
      attendance: session.attendances.find_by(user_id: current_user.id)&.status,
      attendance_note: session.attendances.find_by(user_id: current_user.id)&.note
    }
  end
  def training_session_params
    params.require(:training_session).permit(:date, :description, :loopscholing, :fase, :wedstrijd, :dag, :trainer_id, :location)
  end
end 