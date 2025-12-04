class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?, :is_admin?

  # NO CACHE HEADERS - Prevent proxy/CDN caching
  before_action :set_no_cache_headers

  # Error handling - log alle fouten en toon gebruikersvriendelijke pagina
  rescue_from StandardError, with: :handle_error unless Rails.env.development?
  rescue_from ActionView::Template::Error, with: :handle_error unless Rails.env.development?
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActionController::RoutingError, with: :handle_routing_error

  private
  
  def set_no_cache_headers
    # Standard HTTP cache prevention headers
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate, private'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'
    
    # Note: These headers are only effective if nginx is properly configured
    # See config/nginx/hardlopen.metvirgil.nl.conf and NGINX_CACHE_FIX.md
  end

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
  
  # Error handling methods
  def handle_error(exception)
    error_log = ErrorLog.log_error(
      exception,
      request: request,
      user: current_user,
      extra_data: { session_data: session.to_hash }
    )
    
    @error_code = error_log.code
    @error_message = "Er is een fout opgetreden. Geef foutcode #{@error_code} door aan de beheerder."
    
    respond_to do |format|
      format.html { render 'errors/internal_error', status: :internal_server_error, layout: 'application' }
      format.json { render json: { error: @error_message, code: @error_code }, status: :internal_server_error }
    end
  end
  
  def handle_not_found(exception)
    error_log = ErrorLog.log_error(
      exception,
      request: request,
      user: current_user,
      extra_data: { session_data: session.to_hash }
    )
    
    @error_code = error_log.code
    @error_message = "De gevraagde pagina kon niet worden gevonden."
    
    respond_to do |format|
      format.html { render 'errors/not_found', status: :not_found, layout: 'application' }
      format.json { render json: { error: @error_message, code: @error_code }, status: :not_found }
    end
  end
  
  def handle_routing_error(exception)
    handle_not_found(exception)
  end
end
