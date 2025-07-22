class Admin::TilesController < ApplicationController
  before_action :require_admin

  def index
    @roles = %w[user trainer admin]
    @tiles = [
      { key: 'dezeweek', label: 'Deze week', url: '/schema/dezeweek' },
      { key: 'profile', label: 'Mijn Profiel', url: '/profile' },
      { key: 'all_trainings', label: 'Alle trainingen', url: '/schema/alle' },
      { key: 'groups', label: 'Groepen', url: '/groups' },
      { key: 'users', label: 'Hardlopers', url: '/users' },
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
      { key: 'tiles', label: 'Tegels beheren', url: '/admin/tiles' }
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
      TileAssignment.create!(
        role: role,
        tile_key: tile[:key],
        visible: visible,
        show_in_menu: show_in_menu,
        custom_label: tile[:custom_label],
        position: idx
      )
    end
    render json: { success: true }
  rescue => e
    render json: { success: false, error: e.message }, status: 422
  end

  private
  def require_admin
    unless current_user&.has_role?(:admin)
      redirect_to root_path, alert: 'Geen toegang.'
    end
  end
end 