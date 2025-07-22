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
    Rails.logger.info "[DEBUG] Attendance create params: #{params.inspect}"
    begin
      user_id = current_user.admin? ? (params[:attendance] ? params[:attendance][:user_id] : params[:user_id]) : current_user.id
      training_session_id = params[:attendance] ? params[:attendance][:training_session_id] : params[:training_session_id]
      Rails.logger.info "[DEBUG] Attendance create params: #{params.inspect} | user_id: #{user_id}, training_session_id: #{training_session_id}"
      @attendance = Attendance.find_or_initialize_by(user_id: user_id, training_session_id: training_session_id)
      if @attendance.new_record?
        Rails.logger.info "[DEBUG] Attendance wordt nieuw aangemaakt voor user_id=#{user_id}, training_session_id=#{training_session_id}"
      else
        Rails.logger.info "[DEBUG] Attendance wordt opgehaald voor user_id=#{user_id}, training_session_id=#{training_session_id} (id: #{@attendance.id})"
      end
      Rails.logger.info "[DEBUG] Attendance status voor opslaan: #{@attendance.status.inspect} (params: #{params[:status]})"
      status_map = { '0' => :aanwezig, '1' => :afwezig, 0 => :aanwezig, 1 => :afwezig, 'aanwezig' => :aanwezig, 'afwezig' => :afwezig, 'onbekend' => :onbekend }
      status_param = params[:attendance] ? params[:attendance][:status] : params[:status]
      @attendance.status = status_map[status_param]
      @attendance.note = params[:note]
      if @attendance.save
        Rails.logger.info "[DEBUG] Attendance status na opslaan: #{@attendance.status.inspect} (id: #{@attendance.id})"
        AttendanceMailer.notify_change(@attendance, @attendance.status == 'afwezig' ? 'afgemeld' : 'aangemeld').deliver_later
        respond_to do |format|
          format.html { redirect_back fallback_location: schema_path, notice: "Aanwezigheid bijgewerkt." }
          format.js   { render :create }
        end
      else
        Rails.logger.error "[ERROR] Attendance save failed: #{@attendance.errors.full_messages.join(", ")}"
        week = params[:week] || @attendance.training_session&.week
        year = @attendance.training_session&.date&.cwyear || Date.today.cwyear
        render plain: "Fout bij opslaan aanwezigheid: #{@attendance.errors.full_messages.join(", ")}", status: 422
      end
    rescue => e
      Rails.logger.error "[EXCEPTION] Attendance create: #{e.message}\n#{e.backtrace.join("\n")}"
      render plain: "Onverwachte fout: #{e.message}", status: 500
    end
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    @attendance = Attendance.find(params[:id])
    @attendance.update(status: params[:status], note: params[:note])
    AttendanceMailer.notify_change(@attendance, @attendance.status == 'afwezig' ? 'afgemeld' : 'aangemeld').deliver_later
    respond_to do |format|
      format.html { redirect_back fallback_location: trainings_path, notice: "Status bijgewerkt." }
      format.js   { render :update }
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
