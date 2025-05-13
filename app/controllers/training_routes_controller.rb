class TrainingRoutesController < ApplicationController
  before_action :set_training_route, only: %i[ show edit update destroy ]

  # GET /training_routes or /training_routes.json
  def index
    @training_routes = TrainingRoute.all
  end

  # GET /training_routes/1 or /training_routes/1.json
  def show
  end

  # GET /training_routes/new
  def new
    @training_route = TrainingRoute.new
  end

  # GET /training_routes/1/edit
  def edit
  end

  # POST /training_routes or /training_routes.json
  def create
    @training_route = TrainingRoute.new(training_route_params)

    respond_to do |format|
      if @training_route.save
        format.html { redirect_to @training_route, notice: "Training route was successfully created." }
        format.json { render :show, status: :created, location: @training_route }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @training_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /training_routes/1 or /training_routes/1.json
  def update
    respond_to do |format|
      if @training_route.update(training_route_params)
        format.html { redirect_to @training_route, notice: "Training route was successfully updated." }
        format.json { render :show, status: :ok, location: @training_route }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @training_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /training_routes/1 or /training_routes/1.json
  def destroy
    @training_route.destroy!

    respond_to do |format|
      format.html { redirect_to training_routes_path, status: :see_other, notice: "Training route was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_training_route
      @training_route = TrainingRoute.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def training_route_params
      params.require(:training_route).permit(:training_id, :route_id)
    end
end
