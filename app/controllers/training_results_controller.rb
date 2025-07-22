class TrainingResultsController < ApplicationController
  before_action :require_user
  before_action :sanitize_time_param!, only: [:create, :update]
  before_action :require_trainer_or_admin!, only: [:new_bulk, :create_bulk]

  def new
    @training_session = TrainingSession.find(params[:id])
    @training_result  = TrainingResult.new(
      training_session: @training_session,
      structured_core:  @training_session.structured_core,
      distance:         @training_session.respond_to?(:distance) ? @training_session.distance : nil
    )
  end

  def create
    @training_session = TrainingSession.find(training_result_params[:training_session_id])
    @training_result = current_user.training_results.new(training_result_params)
    if @training_result.save
      redirect_to mijn_trainingen_path, notice: 'Trainingresultaat opgeslagen.'
    else
      flash.now[:alert] = 'Kon trainingresultaat niet opslaan.'
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @training_result = current_user.training_results.find(params[:id])
    @training_session = @training_result.training_session
  end

  def update
    @training_result = current_user.training_results.find(params[:id])
    if @training_result.update(training_result_params)
      redirect_to mijn_trainingen_path, notice: 'Trainingresultaat bijgewerkt.'
    else
      flash.now[:alert] = 'Kon trainingresultaat niet bijwerken.'
      @training_session = @training_result.training_session
      render :edit, status: :unprocessable_entity
    end
  end

  def new_bulk
    @training_session = TrainingSession.find(params[:id])
    @attendances = @training_session.attendances.where(status: :aanwezig)
    if @attendances.empty?
      redirect_to training_session_path(@training_session), alert: 'Geen aanwezige lopers gevonden.' and return
    end
    @bulk = OpenStruct.new(time: '', distance: '', notes: '')
  end

  def create_bulk
    @training_session = TrainingSession.find(params[:id])
    @attendances = @training_session.attendances.where(status: :aanwezig)
    allowed_params = params.require(:bulk).permit(:time, :distance, :notes)
    # parse once
    time_val = allowed_params[:time]
    if time_val.present? && time_val.include?(':')
      parts=time_val.split(':').map(&:to_i)
      time_sec = parts.length==3 ? parts[0]*3600+parts[1]*60+parts[2] : parts[0]*60+parts[1]
    else
      time_sec = time_val.to_i
    end
    dist_val = allowed_params[:distance].presence
    created = 0
    skipped = 0
    @attendances.each do |att|
      existing = TrainingResult.find_by(user_id: att.user_id, training_session_id: @training_session.id)
      if existing
        # Update if existing record lacks meaningful data
        if existing.time.to_i < 30 || existing.distance.to_f < 0.2
          existing.update(time: time_sec, distance: dist_val, notes: allowed_params[:notes])
          created += 1
        else
          skipped += 1
        end
      else
        tr = TrainingResult.new(user_id: att.user_id, training_session: @training_session,
                                time: time_sec, distance: dist_val, notes: allowed_params[:notes],
                                structured_core: @training_session.structured_core)
        created += 1 if tr.save
      end
    end
    msg = []
    msg << "toegevoegd voor #{created} lopers" if created > 0
    msg << "overgeslagen bij #{skipped} lopers (bestond al)" if skipped > 0
    redirect_to training_session_path(@training_session), notice: "Trainingresultaten #{msg.join(' en ')}."
  end

  def require_trainer_or_admin!
    unless current_user&.admin? || current_user&.has_role?(:trainer)
      redirect_to root_path, alert: 'Niet toegestaan.'
    end
  end

  private

  def sanitize_time_param!
    return unless params[:training_result] && params[:training_result][:time].present?
    params[:training_result][:time] = parse_time_str(params[:training_result][:time])
  end

  def parse_time_str(str)
    parts = str.to_s.split(":").map(&:to_i)
    case parts.length
    when 3
      parts[0]*3600 + parts[1]*60 + parts[2]
    when 2
      parts[0]*60 + parts[1]
    else
      str.to_i
    end
  end

  def training_result_params
    params.require(:training_result).permit(:training_session_id, :time, :distance, :notes, :structured_core)
  end
end 