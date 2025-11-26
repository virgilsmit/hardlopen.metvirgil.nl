class IntakesController < ApplicationController
  def new
    @intake = Intake.new
  end

  def create
    @intake = Intake.new(intake_params)

    if @intake.save
      IntakeMailer.notify(@intake).deliver_now
      redirect_to intake_path, notice: 'Bedankt! We hebben je intake ontvangen en nemen snel contact met je op.'
    else
      flash.now[:alert] = 'Controleer de invoer en probeer het opnieuw.'
      render :new, status: :unprocessable_entity
    end
  end

  private

  def intake_params
    params.require(:intake).permit(
      :first_name,
      :last_name,
      :email,
      :birthdate,
      :gender,
      :emergency_number,
      :loop_experience,
      :desired_pace,
      :cooper_test_meters,
      :goal_2025,
      :shirt_size,
      :injuries,
      :comments
    )
  end
end





