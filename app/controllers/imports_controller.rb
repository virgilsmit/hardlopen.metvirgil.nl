class ImportsController < ApplicationController
  before_action :require_admin

  def new
  end

  def preview
    require 'csv'
    if params[:file].present?
      # Sla bestand op
      dir = Rails.root.join('storage', 'imports')
      FileUtils.mkdir_p(dir)
      filename = "import_#{Time.now.to_i}_#{params[:file].original_filename}"
      path = dir.join(filename)
      File.open(path, 'wb') { |f| f.write(params[:file].read) }
      session[:import_csv_path] = path.to_s
      file = path
      csv = CSV.read(file, headers: true)
      @headers = csv.headers
      @rows = csv.map(&:to_h)
    else
      redirect_to import_path, alert: 'Geen bestand geselecteerd.'
    end
  end

  def create
    require 'csv'
    csv_path = session[:import_csv_path]
    unless csv_path && File.exist?(csv_path)
      render plain: 'Importbestand niet gevonden.' and return
    end
    imported = 0
    skipped = 0
    errors = []
    group = Group.find_or_create_by!(name: 'GAC Recreanten AB')
    CSV.foreach(csv_path, headers: true) do |row|
      email = row['email'] || row['E-mail']
      next unless email.present?
      # Sla dubbele e-mails over
      next if User.exists?(email: email)
      begin
        status_code = (row['status'] || '').strip.upcase
        status_map = {
          'A' => 'actief',
          'D' => 'inactief',
          'Z' => 'ziek',
          'V' => 'vakantie',
          'G' => 'geblesseerd'
        }
        status = status_map[status_code] || 'onbekend'
        user_attrs = {
          email: email,
          name: [row['voornaam'], row['achternaam']].compact.join(' '),
          birthday: (Date.parse(row['geboortedatum']) rescue nil),
          phone: row['noodnummer'],
          injury: row['blessures'],
          status: status,
          password: 'gac2025' # Altijd hetzelfde wachtwoord, CSV wordt genegeerd
        }
        user = User.new(user_attrs)
        user.save!
        group.users << user
        imported += 1
      rescue => e
        errors << "#{email}: #{e.message}"
      end
    end
    render plain: "Import voltooid: #{imported} lopers geïmporteerd, #{skipped} overgeslagen. Fouten: #{errors.join('; ')}"
  end

  # NIEUW: Flexibele import van trainingen uit CSV via service
  def import_trainings
    csv_path = params[:csv_path] || Rails.root.join('app', 'Imports', 'Schema2dehelft2025_Ready.csv')
    result = TrainingImporter.new(csv_path).import
    render plain: result
  end

  # NIEUW: Import via formulier
  def import_trainings_via_form
    if params[:file].present?
      dir = Rails.root.join('storage', 'imports')
      FileUtils.mkdir_p(dir)
      filename = "trainings_#{Time.now.to_i}_#{params[:file].original_filename}"
      path = dir.join(filename)
      File.open(path, 'wb') { |f| f.write(params[:file].read) }
      result = TrainingImporter.new(path.to_s).import
      render plain: result
    else
      redirect_to import_path, alert: 'Geen bestand geselecteerd voor trainingen.'
    end
  end

end 