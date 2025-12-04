class TestController < ApplicationController
  skip_before_action :require_admin, raise: false
  skip_before_action :require_user, raise: false
  
  def error_logs_test
    @error_logs = ErrorLog.order(created_at: :desc).limit(100).to_a
    @stats = {
      total: ErrorLog.count,
      unresolved: ErrorLog.unresolved.count,
      today: ErrorLog.today.count,
      this_week: ErrorLog.this_week.count,
      this_month: ErrorLog.this_month.count,
      by_class: ErrorLog.group(:error_class).count.sort_by { |k, v| -v }.first(10)
    }
    render 'admin/error_logs/index'
  end
end
