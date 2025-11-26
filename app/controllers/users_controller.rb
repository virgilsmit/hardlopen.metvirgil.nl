class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.order(:name)
    @actieve_lopers_count = User.actief.count
  end

  # GET /users/1 or /users/1.json
  def show
    @user = User.find(params[:id])
    @performances = @user.performances.order(date: :desc)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    update_params = user_params
    # Alleen admins kunnen default_training_schema_id aanpassen
    unless current_user&.admin?
      update_params = update_params.except(:default_training_schema_id)
    end
    
    respond_to do |format|
      if @user.update(update_params)
        format.html { redirect_to edit_user_path(@user), notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def register
    @user = User.new
  end

  def create_registration
    Rails.logger.info "Processing registration with params: #{user_params.inspect}"
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id # Log in the user after registration
      Rails.logger.info "User #{@user.email} registered successfully."
      redirect_to root_path, notice: 'Registration successful! Welcome!'
    else
      Rails.logger.error "User registration failed for email #{@user.email || 'unknown'}. Errors: #{@user.errors.full_messages.join(', ')}"
      render :register, status: :unprocessable_entity
    end
  end

  def profile
    unless current_user
      redirect_to login_path, alert: 'Log eerst in om je profiel te bekijken.'
      return
    end

    # admin of trainer kan ?id=<user_id> bekijken
    if params[:id].present? && (current_user.admin? || current_user.trainer?)
      @user = User.find_by(id: params[:id]) || current_user
    else
      @user = current_user
    end
    @performances = @user.performances.order(date: :desc)
  end

  def update_training_days
    @user = (params[:user_id] && (current_user.admin? || current_user.trainer?)) ? User.find(params[:user_id]) : current_user
    if @user.update(training_days: params[:user][:training_days] || [])
      redirect_to request.referer || users_path, notice: 'Trainingsdagen opgeslagen.'
    else
      redirect_to request.referer || users_path, alert: 'Opslaan mislukt: ' + @user.errors.full_messages.join(', ')
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :phone, :emergency_contact, :birthday, :injury, :photo_permission, :password, :password_confirmation, :role, :status_id, :csv_name, :default_training_schema_id, training_days: [], roles: [])
    end
end
