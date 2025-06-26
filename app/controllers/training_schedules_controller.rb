class TrainingSchedulesController < ApplicationController
  before_action :set_training_schedule, only: %i[ show edit update destroy ]

  # GET /training_schedules or /training_schedules.json
  def index
    @training_schedules = TrainingSchedule.all
  end

  # GET /training_schedules/1 or /training_schedules/1.json
  def show
  end

  # GET /training_schedules/new
  def new
    @training_schedule = TrainingSchedule.new
  end

  # GET /training_schedules/1/edit
  def edit
  end

  # POST /training_schedules or /training_schedules.json
  def create
    @training_schedule = TrainingSchedule.new(training_schedule_params)

    respond_to do |format|
      if @training_schedule.save
        format.html { redirect_to @training_schedule, notice: "Training schedule was successfully created." }
        format.json { render :show, status: :created, location: @training_schedule }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_schedules/1 or /training_schedules/1.json
  def update
    respond_to do |format|
      if @training_schedule.update(training_schedule_params)
        format.html { redirect_to @training_schedule, notice: "Training schedule was successfully updated." }
        format.json { render :show, status: :ok, location: @training_schedule }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_schedules/1 or /training_schedules/1.json
  def destroy
    @training_schedule.destroy!

    respond_to do |format|
      format.html { redirect_to training_schedules_path, status: :see_other, notice: "Training schedule was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_schedule
      @training_schedule = TrainingSchedule.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_schedule_params
      params.require(:training_schedule).permit(:group_id, :weekday, :start_time, :end_time, :location, :active)
    end
end
