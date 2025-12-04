class Admin::TilesController < ApplicationController
  before_action :require_admin

  def index
    @roles = %w[user trainer admin]
    @menu_groups = ['Training', 'Beheer', 'Trainers', 'Admin', 'Menu Labels', 'Overig']
    @tiles = [
      # Publieke pagina's
      { key: 'home', label: 'Home', url: '/', desc: 'Homepagina' },
      { key: 'login', label: 'Login', url: '/login', desc: 'Inlogpagina' },
      { key: 'register', label: 'Registreren', url: '/register', desc: 'Registratiepagina voor nieuwe gebruikers' },
      { key: 'intake', label: 'Intake', url: '/intake', desc: 'Publiek intake formulier' },
      { key: 'about', label: 'Over Ons', url: '/about', desc: 'Informatie over de loopgroep' },
      
      # Training pagina's
      { key: 'dezeweek', label: 'Deze week', url: '/schema/dezeweek', desc: 'Trainingen van deze week', menu_group: 'Training' },
      { key: 'all_trainings', label: 'Alle trainingen', url: '/schema/alle', desc: 'Overzicht van alle trainingen', menu_group: 'Training' },
      { key: 'my_trainings', label: 'Mijn trainingen', url: '/mijntrainingen', desc: 'Bekijk je eigen trainingen en prestaties', menu_group: 'Training' },
      { key: 'schema', label: 'Schema', url: '/schema', desc: 'Trainingsschema overzicht', menu_group: 'Training' },
      { key: 'vandaag', label: 'Vandaag', url: '/training_sessions/vandaag', desc: 'Aan-/afmelden voor vandaag', menu_group: 'Training' },
      { key: 'zones', label: 'Zones & drempel', url: '/profile', desc: 'Hartslagzones en drempelwaarden', menu_group: 'Training' },
      
      # Profiel & gebruikers
      { key: 'profile', label: 'Mijn Profiel', url: '/profile', desc: 'Persoonlijk profiel en instellingen' },
      { key: 'users', label: 'Hardlopers', url: '/users', desc: 'Overzicht van alle lopers' },
      { key: 'performances', label: 'Prestaties', url: '/performances', desc: 'Overzicht van prestaties' },
      
      # Beheer
      { key: 'groups', label: 'Groepen', url: '/groups', desc: 'Beheer trainingsgroepen', menu_group: 'Beheer' },
      { key: 'statuses', label: 'Statussen', url: '/statuses', desc: 'Beheer gebruikersstatussen', menu_group: 'Beheer' },
      { key: 'photos', label: 'Foto\'s', url: '/photos', desc: 'Foto galerij', menu_group: 'Beheer' },
      { key: 'drills', label: 'Oefeningen', url: '/drills', desc: 'Beheer loopscholing oefeningen', menu_group: 'Beheer' },
      { key: 'routes', label: 'Routes', url: '/routes', desc: 'Beheer trainingsroutes', menu_group: 'Beheer' },
      { key: 'vacations', label: 'Vakanties', url: '/vacations', desc: 'Beheer vakantieperiodes', menu_group: 'Beheer' },
      { key: 'events', label: 'Hardloop Evenementen', url: '/events', desc: 'Bekijk en beheer hardloop evenementen', menu_group: 'Beheer' },
      
      # Trainers
      { key: 'trainers', label: 'Trainerspagina', url: '/trainers', desc: 'Overzicht voor trainers', menu_group: 'Trainers' },
      { key: 'trainers_overzicht', label: 'Trainers Overzicht', url: '/trainers/overzicht', desc: 'Overzicht trainersgegevens', menu_group: 'Trainers' },
      { key: 'trainers_beheer', label: 'Trainers Beheer', url: '/trainers/beheer', desc: 'Beheer trainers en rechten', menu_group: 'Trainers' },
      { key: 'ad_gemiddelden', label: 'Gemiddelde AD', url: '/trainers/ad_gemiddelden', desc: 'Anaerobe drempel gemiddelden', menu_group: 'Trainers' },
      { key: 'trainers_tijden', label: 'Trainers Tijden', url: '/trainers/tijden', desc: 'Overzicht trainerstijden', menu_group: 'Trainers' },
      { key: 'birthdays', label: 'Alle verjaardagen', url: '/trainers/verjaardagen', desc: 'Verjaardagenlijst', menu_group: 'Trainers' },
      { key: 'birthdays_30', label: 'Komende verjaardagen', url: '/verjaardagen/komende', desc: 'Verjaardagen komende 30 dagen', menu_group: 'Trainers' },
      { key: 'log_bulk', label: 'Aanwezig loggen', url: '/schema/dezeweek', desc: 'Bulk aanwezigheid registreren', menu_group: 'Trainers' },
      
      # Admin
      { key: 'admin', label: 'Admin dashboard', url: '/admin', desc: 'Administratie overzicht', menu_group: 'Admin' },
      { key: 'tiles', label: 'Menu beheren', url: '/admin/tiles', desc: 'Beheer menu items en zichtbaarheid', menu_group: 'Admin' },
      { key: 'themes', label: 'Thema beheer', url: '/admin/themes', desc: 'Beheer kleuren en design', menu_group: 'Admin' },
      { key: 'site_contents', label: 'Hero Content', url: '/site_contents', desc: 'Beheer homepage tekst en knoppen', menu_group: 'Admin' },
      { key: 'intakes', label: 'Intake-aanvragen', url: '/admin/intakes', desc: 'Bekijk en verwerk intake aanvragen', menu_group: 'Admin' },
      { key: 'admin_users', label: 'Gebruikers beheer', url: '/admin/users', desc: 'Beheer gebruikersrollen', menu_group: 'Admin' },
      { key: 'admin_schemas', label: 'Schema\'s koppelen', url: '/admin/schemas/koppelen', desc: 'Koppel schema\'s aan gebruikers', menu_group: 'Admin' },
      { key: 'import', label: 'Importeren', url: '/import', desc: 'Importeer trainingsdata', menu_group: 'Admin' },
      { key: 'import_history', label: 'Import Historie', url: '/import_history', desc: 'Bekijk import geschiedenis', menu_group: 'Admin' },
      { key: 'login_logs', label: 'Login Logs', url: '/admin/login_logs', desc: 'Bekijk login geschiedenis', menu_group: 'Admin' },
      { key: 'error_logs', label: 'Error Logs', url: '/admin/error_logs', desc: 'Bekijk en beheer error logs', menu_group: 'Admin' },
      { key: 'error_messages', label: 'Foutmelding Beheer', url: '/admin/error_messages', desc: 'Beheer gebruikersvriendelijke foutmeldingen', menu_group: 'Admin' },
      
      # Menu titels (voor dropdown labels)
      { key: 'menu_training', label: '🏃‍♂️ Training', url: '#', desc: 'Training dropdown menu titel (alleen voor label aanpassing)', menu_group: 'Menu Labels' },
      { key: 'menu_beheer', label: '⚙️ Beheer', url: '#', desc: 'Beheer dropdown menu titel (alleen voor label aanpassing)', menu_group: 'Menu Labels' },
      { key: 'menu_trainers', label: '🧑‍🏫 Trainers', url: '#', desc: 'Trainers dropdown menu titel (alleen voor label aanpassing)', menu_group: 'Menu Labels' },
      { key: 'menu_admin', label: '🛠️ Admin', url: '#', desc: 'Admin dropdown menu titel (alleen voor label aanpassing)', menu_group: 'Menu Labels' }
    ]
    
    # Groepeer tiles per menu groep
    @tiles_by_group = @tiles.group_by { |t| t[:menu_group] || 'Overig' }
    @tile_assignments = TileAssignment.all.group_by { |ta| [ta.role, ta.tile_key] }
  end

  def update
    assignment = TileAssignment.find_or_initialize_by(role: params[:role], tile_key: params[:tile_key])
    assignment.visible = params[:visible]
    if assignment.save
      render json: { success: true }
    else
      render json: { success: false, errors: assignment.errors.full_messages }, status: 422
    end
  end

  def update_label
    assignment = TileAssignment.find_or_initialize_by(role: params[:role], tile_key: params[:tile_key])
    assignment.custom_label = params[:custom_label]
    assignment.visible = true if assignment.visible.nil? # fallback
    if assignment.save
      render json: { success: true }
    else
      render json: { success: false, errors: assignment.errors.full_messages }, status: 422
    end
  end

  def update_order
    role = params[:role]
    tile_keys = params[:tile_keys] || []
    tile_keys.each_with_index do |tile_key, idx|
      assignment = TileAssignment.find_or_initialize_by(role: role, tile_key: tile_key)
      assignment.position = idx
      assignment.visible = true if assignment.visible.nil?
      assignment.save!
    end
    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }, status: 422
  end

  def save_all
    role = params[:role]
    tiles_params = params[:tiles] || {}
    
    # Verwijder oude assignments voor deze rol
    TileAssignment.where(role: role).delete_all
    
    # Convert hash to array and iterate
    tiles_params.values.each do |tile_data|
      parent_menu = tile_data[:parent_menu].presence
      show_in_menu = tile_data[:show_in_menu] == '1'
      
      TileAssignment.create!(
        role: role,
        tile_key: tile_data[:key],
        visible: tile_data[:visible] == '1',
        show_in_menu: show_in_menu,
        show_as_shortcut: tile_data[:show_as_shortcut] == '1',
        parent_menu: parent_menu,
        show_in_parent_dropdown: parent_menu.present? && show_in_menu,
        position: tile_data[:position].to_i,
        custom_label: tile_data[:custom_label].presence,
        custom_menu_label: tile_data[:custom_menu_label].presence,
        show_in_bottom_nav: tile_data[:show_in_bottom_nav] == '1',
        bottom_nav_icon: tile_data[:bottom_nav_icon].presence,
        bottom_nav_label: tile_data[:bottom_nav_label].presence,
        bottom_nav_position: tile_data[:bottom_nav_position].to_i
      )
    end
    redirect_to admin_tiles_path(saved: true), notice: 'Menu instellingen opgeslagen.'
  rescue => e
    Rails.logger.error "Error saving tiles: #{e.message}\n#{e.backtrace.join("\n")}"
    redirect_to admin_tiles_path, alert: "Fout bij opslaan: #{e.message}"
  end
end 