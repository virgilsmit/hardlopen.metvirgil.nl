module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all.order(:id)
    end

    def update_role
      @user = User.find(params[:id])
      
      # Gebruik de enum direct (Rails converteert automatisch)
      if @user.update(role: params[:role])
        redirect_to admin_users_path, notice: 'Rol bijgewerkt.'
      else
        redirect_to admin_users_path, alert: 'Bijwerken mislukt.'
      end
    end
  end
end 