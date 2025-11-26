class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :is_admin?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_user
    unless logged_in?
      flash[:alert] = "You must be logged in to perform that action."
      redirect_to login_path
    end
  end
  
  # Consistente check voor admin/beheerder - ondersteunt zowel oude role enum als nieuwe roles array
  def is_admin?
    return false unless current_user
    # Check nieuwe roles array (prioriteit)
    return true if current_user.has_role?(:admin)
    # Check oude role enum (fallback)
    return true if current_user.role == 'admin' || current_user[:role] == 2
    # Check admin? methode (extra fallback)
    current_user.admin? rescue false
  end
  
  def require_admin
    unless is_admin?
      redirect_to root_path, alert: 'Alleen beheerders mogen dit zien.'
    end
  end
end
