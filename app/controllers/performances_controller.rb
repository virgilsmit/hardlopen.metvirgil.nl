class PerformancesController < ApplicationController
  before_action :set_performance, only: %i[ show edit update destroy ]

  # GET /performances or /performances.json
  def index
    @performances = Performance.all
  end

  # GET /performances/1 or /performances/1.json
  def show
  end

  # GET /performances/new
  def new
    @performance = Performance.new
  end

  # GET /performances/1/edit
  def edit
  end

  # POST /performances or /performances.json
  def create
    @performance = Performance.new(performance_params)
    unless User.exists?(@performance.user_id)
      redirect_to profile_path, alert: 'Ongeldige loper geselecteerd.' and return
    end

    respond_to do |format|
      if @performance.save
        if current_user.id == @performance.user_id
          format.html { redirect_to profile_path, notice: "Prestatie succesvol toegevoegd." }
        else
          format.html { redirect_to user_path(@performance.user_id), notice: "Prestatie succesvol toegevoegd voor loper." }
        end
        format.json { render :show, status: :created, location: @performance }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @performance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /performances/1 or /performances/1.json
  def update
    respond_to do |format|
      if @performance.update(performance_params)
        format.html { redirect_to user_path(@performance.user_id), notice: "Prestatie succesvol aangepast." }
        format.json { render :show, status: :ok, location: @performance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @performance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /performances/1 or /performances/1.json
  def destroy
    if current_user&.admin? || @performance.user_id == current_user&.id
      user_id = @performance.user_id
      @performance.destroy!
      respond_to do |format|
        format.html { redirect_to user_path(user_id), status: :see_other, notice: "Prestatie verwijderd." }
        format.json { head :no_content }
      end
    else
      redirect_to profile_path, alert: "Je mag deze prestatie niet verwijderen."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_performance
      @performance = Performance.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def performance_params
      params.require(:performance).permit(:user_id, :test_type, :value, :date, :notes, :distance)
    end
end
