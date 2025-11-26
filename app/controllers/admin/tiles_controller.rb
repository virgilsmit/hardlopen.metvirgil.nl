class Admin::TilesController < ApplicationController
  before_action :require_admin

  def index
    @roles = %w[user trainer admin]
    @tiles = [
      { key: 'home', label: 'Home', url: '/', desc: 'Homepagina' },
      { key: 'login', label: 'Login', url: '/login', desc: 'Inlogpagina' },
      { key: 'register', label: 'Registreren', url: '/register', desc: 'Registratiepagina voor nieuwe gebruikers' },
      { key: 'intake', label: 'Intake', url: '/intake', desc: 'Publiek intake formulier' },
      { key: 'dezeweek', label: 'Deze week', url: '/schema/dezeweek' },
      { key: 'profile', label: 'Mijn Profiel', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', url: '/schema/alle' },
      { key: 'my_trainings', label: 'Mijn trainingen', url: '/mijntrainingen', desc: 'Bekijk je eigen trainingen en prestaties' },
      { key: 'groups', label: 'Groepen', url: '/groups' },
      { key: 'users', label: 'Hardlopers', url: '/users' },
      { key: 'profielen', label: 'Profielen', url: '/users', desc: 'Bekijk alle gebruikersprofielen' },
      { key: 'photos', label: 'Foto\'s', url: '/photos' },
      { key: 'about', label: 'Over Ons', url: '/about' },
      { key: 'schema', label: 'Schema', url: '/schema' },
      { key: 'import', label: 'Importeren', url: '/import' },
      { key: 'statuses', label: 'Statussen', url: '/statuses' },
      { key: 'admin', label: 'Admin dashboard', url: '/admin' },
      { key: 'trainers', label: 'Trainerspagina', url: '/trainers' },
      { key: 'vandaag', label: 'Vandaag afmelden', url: '/training_sessions/vandaag' },
      { key: 'trainers_overzicht', label: 'Trainers Overzicht', url: '/trainers/overzicht' },
      { key: 'ad_gemiddelden', label: 'Gemiddelde AD Lopers', url: '/trainers/ad_gemiddelden' },
      { key: 'birthdays', label: 'Alle verjaardagen', url: '/trainers/verjaardagen' },
      { key: 'birthdays_30', label: 'Komende verjaardagen', url: '/verjaardagen/komende' },
      { key: 'log_bulk', label: 'Aanwezig loggen', url: '/schema/dezeweek' },
      { key: 'tiles', label: 'Tegels beheren', url: '/admin/tiles' },
      { key: 'intakes', label: 'Intake-aanvragen', url: '/admin/intakes', desc: 'Bekijk en verwerk nieuwe intake aanvragen' },
      { key: 'apple_watch_download', label: 'Apple Watch Download', url: '#', desc: 'Toon download knop voor Apple Watch/iPhone' }
    ]
    @tile_assignments = TileAssignment.all.group_by { |ta| [ta.role, ta.tile_key] }
    # In een echte app zou je hier de tegel-instellingen per rol uit de database halen
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
    tiles = params[:tiles] || []
    TileAssignment.where(role: role).delete_all
    tiles.each_with_index do |tile, idx|
      visible = tile[:visible].to_s == '1' || tile[:visible] == true
      show_in_menu = tile[:show_in_menu].to_s == '1' || tile[:show_in_menu] == true || tile[:show_in_menu].nil?
      show_apple_watch_download = tile[:show_apple_watch_download].to_s == '1' || tile[:show_apple_watch_download] == true
      TileAssignment.create!(
        role: role,
        tile_key: tile[:key],
        visible: visible,
        show_in_menu: show_in_menu,
        show_apple_watch_download: show_apple_watch_download,
        custom_label: tile[:custom_label],
        position: idx
      )
    end
    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }, status: 422
  end

end 