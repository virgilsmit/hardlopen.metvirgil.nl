class SiteContentsController < ApplicationController
  before_action :require_admin
  
  def index
    @hero_eyebrow = SiteContent.get('hero_eyebrow', 'Loopgroep Virgil')
    @hero_title = SiteContent.get('hero_title', 'Tempo op de baan, focus op vooruitgang.')
    @hero_description = SiteContent.get('hero_description', 'Een track-geïnspireerde coaching experience met dezelfde tools als je gewend bent: schema\'s, aanwezigheden en resultaten blijven exact werken zoals op de oude site.')
    @hero_buttons = HeroButton.ordered
  end
  
  def update
    SiteContent.set('hero_eyebrow', params[:hero_eyebrow]) if params[:hero_eyebrow].present?
    SiteContent.set('hero_title', params[:hero_title]) if params[:hero_title].present?
    SiteContent.set('hero_description', params[:hero_description]) if params[:hero_description].present?
    
    redirect_to site_contents_path, notice: 'Hero content succesvol bijgewerkt.'
  end
  
  def create_button
    @button = HeroButton.new(hero_button_params)
    if @button.save
      redirect_to site_contents_path, notice: 'Knop succesvol toegevoegd.'
    else
      @hero_eyebrow = SiteContent.get('hero_eyebrow', 'Loopgroep Virgil')
      @hero_title = SiteContent.get('hero_title', 'Tempo op de baan, focus op vooruitgang.')
      @hero_description = SiteContent.get('hero_description', 'Een track-geïnspireerde coaching experience met dezelfde tools als je gewend bent: schema\'s, aanwezigheden en resultaten blijven exact werken zoals op de oude site.')
      @hero_buttons = HeroButton.ordered
      flash.now[:alert] = "Fout bij toevoegen knop: #{@button.errors.full_messages.join(', ')}"
      render :index
    end
  end
  
  def update_button
    @button = HeroButton.find(params[:id])
    if @button.update(hero_button_params)
      redirect_to site_contents_path, notice: 'Knop succesvol bijgewerkt.'
    else
      @hero_eyebrow = SiteContent.get('hero_eyebrow', 'Loopgroep Virgil')
      @hero_title = SiteContent.get('hero_title', 'Tempo op de baan, focus op vooruitgang.')
      @hero_description = SiteContent.get('hero_description', 'Een track-geïnspireerde coaching experience met dezelfde tools als je gewend bent: schema\'s, aanwezigheden en resultaten blijven exact werken zoals op de oude site.')
      @hero_buttons = HeroButton.ordered
      flash.now[:alert] = "Fout bij bijwerken knop: #{@button.errors.full_messages.join(', ')}"
      render :index
    end
  end
  
  def destroy_button
    @button = HeroButton.find(params[:id])
    @button.destroy
    redirect_to site_contents_path, notice: 'Knop succesvol verwijderd.'
  end
  
  private
  
  def hero_button_params
    params.require(:hero_button).permit(:label, :url, :icon, :style, :position, :visible, :description, :user_type, :role)
  end
end

