class TrainingDrillsController < ApplicationController
  before_action :set_training_drill, only: %i[ show edit update destroy ]

  # GET /training_drills or /training_drills.json
  def index
    @training_drills = TrainingDrill.all
  end

  # GET /training_drills/1 or /training_drills/1.json
  def show
  end

  # GET /training_drills/new
  def new
    @training_drill = TrainingDrill.new
  end

  # GET /training_drills/1/edit
  def edit
  end

  # POST /training_drills or /training_drills.json
  def create
    @training_drill = TrainingDrill.new(training_drill_params)

    respond_to do |format|
      if @training_drill.save
        format.html { redirect_to @training_drill, notice: "Training drill was successfully created." }
        format.json { render :show, status: :created, location: @training_drill }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_drill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_drills/1 or /training_drills/1.json
  def update
    respond_to do |format|
      if @training_drill.update(training_drill_params)
        format.html { redirect_to @training_drill, notice: "Training drill was successfully updated." }
        format.json { render :show, status: :ok, location: @training_drill }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_drill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_drills/1 or /training_drills/1.json
  def destroy
    @training_drill.destroy!

    respond_to do |format|
      format.html { redirect_to training_drills_path, status: :see_other, notice: "Training drill was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_drill
      @training_drill = TrainingDrill.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_drill_params
      params.require(:training_drill).permit(:training_session_id, :drill_id)
    end
end
