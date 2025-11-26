class PasswordResetsController < ApplicationController
  # GET /password_resets/new
  def new
  end

  # POST /password_resets
  def create
    @user = User.find_by(email: params[:email])
    if @user&.status&.name == 'actief'
      token = @user.generate_password_reset_token!
      PasswordResetMailer.reset_email(@user).deliver_later
    end
    redirect_to login_path, notice: 'Als het e-mailadres bestaat, is er een instructiemail verstuurd.'
  end

  # GET /password_resets/:id/edit (id == token)
  def edit
    @user = User.find_by(reset_password_token: params[:id])
    if @user.nil? || @user.password_reset_expired?
      redirect_to new_password_reset_path, alert: 'Wachtwoord reset link is ongeldig of verlopen.'
    end
  end

  # PATCH /password_resets/:id
  def update
    @user = User.find_by(reset_password_token: params[:id])
    if @user.nil? || @user.password_reset_expired? || @user.status&.name != 'actief'
      redirect_to new_password_reset_path, alert: 'Wachtwoord reset link is ongeldig of verlopen.' and return
    end

    if @user.update(password_params)
      @user.clear_password_reset_token!
      redirect_to login_path, notice: 'Wachtwoord succesvol bijgewerkt. Je kunt nu inloggen.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end 