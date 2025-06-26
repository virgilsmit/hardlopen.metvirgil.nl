module Admin
  class DashboardController < ApplicationController
    before_action :require_admin

    def index
    end

    private
    def require_admin
      unless current_user&.role == 'admin'
        redirect_to root_path, alert: 'Alleen beheerders mogen dit zien.'
      end
    end
  end
end 