class Admin::LoginLogsController < ApplicationController
  before_action :require_admin
  
  def index
    @login_logs = LoginLog.includes(:user).order(logged_in_at: :desc)
    
    # Filter opties
    if params[:user_id].present?
      @login_logs = @login_logs.where(user_id: params[:user_id])
    end
    
    if params[:date_from].present?
      @login_logs = @login_logs.where('logged_in_at >= ?', params[:date_from])
    end
    
    if params[:date_to].present?
      @login_logs = @login_logs.where('logged_in_at <= ?', params[:date_to])
    end
    
    # Limiteer tot laatste 500 logs
    @login_logs = @login_logs.limit(500)
    
    @users = User.order(:name)
  end
end
