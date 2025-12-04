class SessionsController < ApplicationController
  # Adjusted before_action to exclude custom authentication actions
  before_action :set_session, only: %i[ show edit update ] # Removed :destroy from this line

  # GET /sessions or /sessions.json
  def index
    @sessions = Session.all
  end

  # GET /sessions/1 or /sessions/1.json
  def show
  end

  # GET /sessions/new (scaffolded, for creating a 'session' resource, not user login)
  # To avoid conflict, we can rename this or ensure routes are specific.
  # For now, let's assume the login 'new' below is correctly routed.
  # def new
  #   @session = Session.new
  # end

  # GET /sessions/1/edit
  def edit
  end

  # POST /sessions or /sessions.json (scaffolded)
  # def create
  #   @session = Session.new(session_params)
  #   # ... scaffolded create logic ...
  # end

  # PATCH/PUT /sessions/1 or /sessions/1.json
  def update
    respond_to do |format|
      if @session.update(session_params)
        format.html { redirect_to @session, notice: "Session was successfully updated." }
        format.json { render :show, status: :ok, location: @session }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @session.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions/1 or /sessions/1.json (This is the scaffolded destroy, which we are removing to avoid conflict)
  # def destroy
  #   @session.destroy!
  #
  #   respond_to do |format|
  #     format.html { redirect_to sessions_path, status: :see_other, notice: "Session was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  # GET /login - User login form
  def new
    # This 'new' is for user login, not creating a 'session' resource.
    # If @session was used here for form_with model, it might conflict.
    # However, typical login forms don't need a @session object.
  end

  # POST /login - User login authentication
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      
      # Log de login
      LoginLog.create(
        user: user,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
        logged_in_at: Time.current
      )
      
      redirect_to root_path, notice: 'Logged in successfully!'
    else
      flash.now[:alert] = 'Invalid email or password'
      render :new, status: :unprocessable_entity # Renders login 'new'
    end
  end

  # DELETE /logout - User logout
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Logged out successfully!', status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session
      @session = Session.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def session_params
      params.require(:session).permit(:group_id, :title, :description, :start_time, :end_time, :trainer_name)
    end
end
