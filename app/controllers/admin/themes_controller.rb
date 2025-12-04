class Admin::ThemesController < ApplicationController
  before_action :require_admin
  before_action :set_theme, only: [:show, :edit, :update, :destroy, :activate]

  def index
    @themes = Theme.all.order(active: :desc, created_at: :desc)
    @current_theme = Theme.current
  end

  def show
  end

  def new
    @theme = Theme.new
    # Kopieer waarden van huidige actieve thema als basis
    if current_theme = Theme.current
      @theme.attributes = current_theme.attributes.except('id', 'name', 'active', 'created_at', 'updated_at')
      @theme.name = "Nieuw thema #{Time.current.strftime('%Y%m%d')}"
    end
  end

  def create
    @theme = Theme.new(theme_params)
    @theme.active = false unless params[:theme][:activate] == '1'
    
    if @theme.save
      if params[:theme][:activate] == '1'
        @theme.update(active: true)
      end
      redirect_to admin_themes_path, notice: 'Thema succesvol aangemaakt.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @theme.update(theme_params)
      if params[:theme][:activate] == '1'
        @theme.update(active: true)
      end
      redirect_to admin_themes_path, notice: 'Thema succesvol bijgewerkt.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @theme.active?
      redirect_to admin_themes_path, alert: 'Je kunt het actieve thema niet verwijderen. Activeer eerst een ander thema.'
    else
      @theme.destroy
      redirect_to admin_themes_path, notice: 'Thema succesvol verwijderd.'
    end
  end

  def activate
    @theme.update(active: true)
    redirect_to admin_themes_path, notice: 'Thema geactiveerd.'
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(
      :name, :active,
      :primary_color, :secondary_color, :accent_color,
      :success_color, :warning_color, :danger_color,
      :background_color, :background_color_alt,
      :header_background, :card_background, :card_background_dark,
      :text_color_light, :text_color_dark,
      :text_color_muted, :text_color_muted_dark,
      :border_color, :border_color_dark,
      :font_family, :font_family_secondary,
      :font_size_base, :font_weight_normal, :font_weight_semibold, :font_weight_bold,
      :spacing_unit,
      :border_radius_small, :border_radius_medium, :border_radius_large,
      :shadow_small, :shadow_medium, :shadow_large,
      :custom_css
    )
  end
end









