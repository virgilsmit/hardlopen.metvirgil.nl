class TrainingSessionsController < ApplicationController
  def show
    @training_session = TrainingSession.find(params[:id])
  end
end 