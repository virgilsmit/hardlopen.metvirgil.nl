class AttendancesController < ApplicationController
  before_action :set_attendance, only: %i[ show edit update destroy ]
  before_action :require_login

  # GET /attendances or /attendances.json
  def index
    @attendances = Attendance.all
  end

  # GET /attendances/1 or /attendances/1.json
  def show
  end

  # GET /attendances/new
  def new
    @attendance = Attendance.new
  end

  # GET /attendances/1/edit
  def edit
  end

  # POST /attendances or /attendances.json
  def create
    Rails.logger.info "[DEBUG] Attendance create RAW params: #{params.inspect}"
    begin
      # Flexibel parameters ophalen - zowel genest als niet-genest
      att_params = params[:attendance] || params
      
      # User ID bepalen - admin kan andere users aanmelden, anders current_user
      user_id = if current_user.admin? || current_user.has_role?(:trainer)
        att_params[:user_id].to_i
      else
        current_user.id
      end
      
      training_session_id = att_params[:training_session_id].to_i
      
      Rails.logger.info "[DEBUG] Extracted: user_id=#{user_id}, training_session_id=#{training_session_id}"
      
      # Valideer dat user en training session bestaan
      unless User.exists?(user_id) && TrainingSession.exists?(training_session_id)
        Rails.logger.error "[ERROR] User (#{user_id}) or TrainingSession (#{training_session_id}) niet gevonden"
        render plain: "Fout: Gebruiker of training niet gevonden", status: 422
        return
      end
      
      @attendance = Attendance.find_or_initialize_by(user_id: user_id, training_session_id: training_session_id)
      
      if @attendance.new_record?
        Rails.logger.info "[DEBUG] Nieuwe attendance voor user_id=#{user_id}, training_session_id=#{training_session_id}"
      else
        Rails.logger.info "[DEBUG] Bestaande attendance (id: #{@attendance.id})"
      end
      
      # Status bepalen
      status_map = { '0' => 'aanwezig', '1' => 'afwezig', 0 => 'aanwezig', 1 => 'afwezig', 'aanwezig' => 'aanwezig', 'afwezig' => 'afwezig', 'onbekend' => 'onbekend' }
      status_param = att_params[:status].to_s
      mapped_status = status_map[status_param] || status_param
      
      Rails.logger.info "[DEBUG] Status param: '#{status_param}' -> mapped: '#{mapped_status}'"
      
      @attendance.status = mapped_status
      @attendance.note = att_params[:note].to_s if att_params[:note].present?
      
      Rails.logger.info "[DEBUG] Voor opslaan - status: #{@attendance.status.inspect}, note: #{@attendance.note.inspect}"
      
      if @attendance.save
        Rails.logger.info "[DEBUG] Attendance opgeslagen! (id: #{@attendance.id}, status: #{@attendance.status})"
        AttendanceMailer.notify_change(@attendance, @attendance.status == 'afwezig' ? 'afgemeld' : 'aangemeld').deliver_later
        respond_to do |format|
          format.html { redirect_back fallback_location: schema_path, notice: "Status bijgewerkt." }
          format.js   { render :create }
        end
      else
        Rails.logger.error "[ERROR] Attendance save failed: #{@attendance.errors.full_messages.join(", ")}"
        respond_to do |format|
          format.html { render plain: "Fout bij opslaan aanwezigheid: #{@attendance.errors.full_messages.join(", ")}", status: 422 }
          format.js   { render js: "alert('Fout: #{@attendance.errors.full_messages.join(", ")}');" }
        end
      end
    rescue => e
      Rails.logger.error "[EXCEPTION] Attendance create: #{e.message}\n#{e.backtrace.join("\n")}"
      render plain: "Onverwachte fout: #{e.message}", status: 500
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    @attendance = Attendance.find(params[:id])
    status_param = params[:attendance] ? params[:attendance][:status] : params[:status]
    note_param = params[:attendance] ? params[:attendance][:note] : params[:note]
    if @attendance.update(status: status_param, note: note_param)
      AttendanceMailer.notify_change(@attendance, @attendance.status == 'afwezig' ? 'afgemeld' : 'aangemeld').deliver_later
      respond_to do |format|
        format.html { redirect_back fallback_location: trainings_path, notice: "Status bijgewerkt." }
        format.js   { render :update }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: trainings_path, alert: "Fout: #{@attendance.errors.full_messages.join(', ')}" }
        format.js   { render js: "alert('Fout: #{@attendance.errors.full_messages.join(', ')}');" }
      end
    end
  end

  # DELETE /attendances/1 or /attendances/1.json
  def destroy
    @attendance.destroy!

    respond_to do |format|
      format.html { redirect_to attendances_path, status: :see_other, notice: "Attendance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendance
      @attendance = Attendance.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def attendance_params
      params.require(:attendance).permit(:user_id, :training_session_id, :status, :note)
    end

    def require_login
      redirect_to login_path unless logged_in?
    end
end
