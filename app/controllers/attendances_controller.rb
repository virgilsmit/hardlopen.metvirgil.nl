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
    @training = Training.find(params[:training_id])
    attendance = @training.attendances.find_or_initialize_by(user: current_user)
    attendance.status = params[:status]
    attendance.save
    redirect_to trainings_path, notice: "Aanwezigheid bijgewerkt."
  end

  # PATCH/PUT /attendances/1 or /attendances/1.json
  def update
    @attendance = Attendance.find(params[:id])
    @attendance.update(status: params[:status])
    redirect_back fallback_location: trainings_path, notice: "Status bijgewerkt."
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
      params.require(:attendance).permit(:user_id, :training_session_id, :status) # Changed from training_id
    end

    def require_login
      redirect_to login_path unless logged_in?
    end
end
