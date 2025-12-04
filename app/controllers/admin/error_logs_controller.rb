class Admin::ErrorLogsController < ApplicationController
  before_action :require_admin
  before_action :set_error_log, only: [:show, :resolve, :reopen, :update_notes, :destroy]

  def index
    # Tab filter: Actief (unresolved) of Archief (resolved)
    if params[:tab] == 'archive'
      @error_logs = ErrorLog.resolved.recent.limit(100)
      @active_tab = 'archive'
    else
      @error_logs = ErrorLog.unresolved.recent.limit(100)
      @active_tab = 'active'
    end
    
    # Extra filters (alleen als niet in archief tab)
    if params[:tab] != 'archive'
      if params[:error_class].present?
        @error_logs = @error_logs.by_class(params[:error_class])
      end
      
      if params[:period] == 'today'
        @error_logs = @error_logs.today
      elsif params[:period] == 'week'
        @error_logs = @error_logs.this_week
      elsif params[:period] == 'month'
        @error_logs = @error_logs.this_month
      end
    end
    
    @error_logs = @error_logs.to_a  # Execute query, return array
    
    # Statistieken voor dashboard
    @stats = {
      total: ErrorLog.count,
      unresolved: ErrorLog.unresolved.count,
      today: ErrorLog.today.count,
      this_week: ErrorLog.this_week.count,
      this_month: ErrorLog.this_month.count,
      by_class: ErrorLog.group(:error_class).count.sort_by { |k, v| -v }.first(10)
    }
  end

  def show
    # Detail view met volledige backtrace en context
  end

  def resolve
    if @error_log.resolve!(current_user, notes: params[:notes])
      redirect_to admin_error_log_path(@error_log), notice: 'Fout gemarkeerd als opgelost.'
    else
      redirect_to admin_error_log_path(@error_log), alert: 'Kon fout niet markeren als opgelost.'
    end
  end

  def reopen
    if @error_log.reopen!
      redirect_to admin_error_log_path(@error_log), notice: 'Fout heropend.'
    else
      redirect_to admin_error_log_path(@error_log), alert: 'Kon fout niet heropenen.'
    end
  end

  def update_notes
    if @error_log.update(notes: params[:notes])
      redirect_to admin_error_log_path(@error_log), notice: 'Notities bijgewerkt.'
    else
      redirect_to admin_error_log_path(@error_log), alert: 'Kon notities niet bijwerken.'
    end
  end

  def destroy
    @error_log.destroy
    redirect_to admin_error_logs_path, notice: 'Error log verwijderd.'
  end

  def bulk_resolve
    error_logs = ErrorLog.where(id: params[:error_log_ids])
    error_logs.each { |log| log.resolve!(current_user) }
    redirect_to admin_error_logs_path, notice: "#{error_logs.count} fouten gemarkeerd als opgelost."
  end

  def bulk_delete
    count = ErrorLog.where(id: params[:error_log_ids]).destroy_all.count
    redirect_to admin_error_logs_path, notice: "#{count} fouten verwijderd."
  end

  def clear_resolved
    count = ErrorLog.resolved.destroy_all.count
    redirect_to admin_error_logs_path, notice: "#{count} opgeloste fouten verwijderd."
  end

  private

  def set_error_log
    @error_log = ErrorLog.find(params[:id])
  end
end

