class TrainingsController < ApplicationController
  before_action :require_login

  def index
    @trainings = Training.all.order(date: :asc)
  end

  def show
    @training = Training.find(params[:id])
  end

  def new
    @training = Training.new
  end

  def create
    @training = Training.new(training_params)
    if @training.save
      redirect_to trainings_path, notice: "Training aangemaakt!"
    else
      render :new
    end
  end

  def edit
    @training = Training.find(params[:id])
  end

  def update
    @training = Training.find(params[:id])
    if @training.update(training_params)
      redirect_to trainings_path, notice: "Training bijgewerkt!"
    else
      render :edit
    end
  end

  def destroy
    @training = Training.find(params[:id])
    @training.destroy
    redirect_to trainings_path, notice: "Training verwijderd."
  end

  private

  def training_params
    params.require(:training).permit(:title, :description, :date)
  end

  def require_login
    redirect_to login_path unless logged_in?
  end
end 