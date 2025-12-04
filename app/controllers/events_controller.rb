class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :require_trainer_or_admin, only: [:new, :create, :edit, :update, :destroy, :import]
  
  def index
    @upcoming_events = Event.visible.upcoming
    @past_events = Event.visible.past.limit(10)
  end
  
  def show
    # Iedereen kan een event bekijken als het visible is
    unless @event.visible?
      redirect_to events_path, alert: 'Dit evenement is niet beschikbaar.'
    end
  end
  
  def new
    @event = Event.new
  end
  
  def create
    @event = Event.new(event_params)
    @event.visible = true
    @event.published = true
    
    if @event.save
      redirect_to events_path, notice: 'Evenement succesvol aangemaakt.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: 'Evenement succesvol bijgewerkt.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Evenement verwijderd.'
  end
  
  def import
    # Import page
  end
  
  def do_import_loopjes_2026
    require_trainer_or_admin
    
    begin
      file_path = Rails.root.join('app', 'Imports', 'Loopjes 2026.xlsx')
      
      unless File.exist?(file_path)
        redirect_to import_events_path, alert: 'Loopjes 2026.xlsx niet gevonden in /app/Imports/'
        return
      end
      
      require 'roo'
      xlsx = Roo::Spreadsheet.open(file_path.to_s)
      sheet = xlsx.sheet(0)
      
      imported = 0
      
      # Loopjes 2026 formaat: Datum | Run | Informatie | Afstand
      (2..sheet.last_row).each do |i|
        date_value = sheet.cell(i, 1)
        event_date = parse_date(date_value)
        next if event_date.nil?
        
        name = sheet.cell(i, 2)&.to_s&.strip
        next if name.blank?
        
        description = sheet.cell(i, 3)&.to_s&.strip
        distance = sheet.cell(i, 4)&.to_s&.strip
        location = name.split(' ').first # Eerste woord als locatie
        
        Event.create!(
          name: name,
          date: event_date,
          location: location,
          distance: distance,
          description: description,
          organizer: nil,
          url: nil,
          price: nil,
          registration_deadline: nil,
          visible: true,
          published: true
        )
        imported += 1
      end
      
      redirect_to events_path, notice: "#{imported} evenementen succesvol geïmporteerd uit Loopjes 2026.xlsx!"
    rescue => e
      redirect_to import_events_path, alert: "Import fout: #{e.message}"
    end
  end
  
  def do_import
    require_trainer_or_admin
    
    if params[:file].blank?
      redirect_to import_events_path, alert: 'Geen bestand geselecteerd.'
      return
    end
    
    begin
      file = params[:file]
      require 'roo'
      
      xlsx = Roo::Spreadsheet.open(file.path)
      sheet = xlsx.sheet(0)
      
      imported = 0
      errors = []
      
      # Assuming columns: Naam | Datum | Locatie | Afstand | Organisator | URL | Beschrijving | Prijs | Inschrijfdeadline
      (2..sheet.last_row).each do |i|
        begin
          event = Event.create!(
            name: sheet.cell(i, 1)&.to_s,
            date: parse_date(sheet.cell(i, 2)),
            location: sheet.cell(i, 3)&.to_s,
            distance: sheet.cell(i, 4)&.to_s,
            organizer: sheet.cell(i, 5)&.to_s,
            url: sheet.cell(i, 6)&.to_s,
            description: sheet.cell(i, 7)&.to_s,
            price: sheet.cell(i, 8)&.to_s,
            registration_deadline: parse_date(sheet.cell(i, 9)),
            visible: true,
            published: true
          )
          imported += 1
        rescue => e
          errors << "Rij #{i}: #{e.message}"
        end
      end
      
      if errors.any?
        redirect_to events_path, notice: "#{imported} evenementen geïmporteerd. #{errors.count} fouten: #{errors.first(3).join(', ')}"
      else
        redirect_to events_path, notice: "#{imported} evenementen succesvol geïmporteerd!"
      end
    rescue => e
      redirect_to import_events_path, alert: "Import fout: #{e.message}"
    end
  end
  
  private
  
  def set_event
    @event = Event.find(params[:id])
  end
  
  def event_params
    params.require(:event).permit(
      :name, :date, :location, :distance, :description, 
      :url, :organizer, :price, :registration_deadline, 
      :visible, :published
    )
  end
  
  def require_trainer_or_admin
    unless current_user&.admin? || current_user&.has_role?(:trainer)
      redirect_to events_path, alert: 'Geen toegang. Alleen trainers en admins.'
    end
  end
  
  def parse_date(value)
    return nil if value.blank?
    return value if value.is_a?(Date)
    Date.parse(value.to_s) rescue nil
  end
end

