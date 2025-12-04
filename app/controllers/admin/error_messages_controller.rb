class Admin::ErrorMessagesController < ApplicationController
  before_action :require_admin
  before_action :set_error_log, only: [:edit, :update]

  def index
    @error_logs = ErrorLog.all.order(created_at: :desc).limit(100)
    @error_codes = ErrorLog.pluck(:code, :id).to_h
  end

  def edit
    # Edit custom user-friendly message for this error code
  end

  def update
    custom_message = params[:custom_message]
    
    if @error_log.update(notes: custom_message)
      redirect_to admin_error_messages_path, notice: "Gebruikersvriendelijke melding bijgewerkt voor #{@error_log.code}"
    else
      render :edit, alert: "Kon melding niet bijwerken"
    end
  end

  private

  def set_error_log
    @error_log = ErrorLog.find(params[:id])
  end
end

