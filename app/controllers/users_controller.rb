class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    @users = User.order(:name)
  end

  # GET /users/1 or /users/1.json
  def show
    @user = User.find(params[:id])
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
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: "User was successfully updated." }
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
    @user = current_user
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :phone, :emergency_contact, :birthday, :injury, :photo_permission, :password, :password_confirmation, :role, :status_id, :csv_name)
    end
end
