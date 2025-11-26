class SiteContentsController < ApplicationController
  before_action :require_admin
  
  def index
    @hero_eyebrow = SiteContent.get('hero_eyebrow', 'Loopgroep Virgil')
    @hero_title = SiteContent.get('hero_title', 'Tempo op de baan, focus op vooruitgang.')
    @hero_description = SiteContent.get('hero_description', 'Een track-geïnspireerde coaching experience met dezelfde tools als je gewend bent: schema\'s, aanwezigheden en resultaten blijven exact werken zoals op de oude site.')
  end
  
  def update
    SiteContent.set('hero_eyebrow', params[:hero_eyebrow]) if params[:hero_eyebrow].present?
    SiteContent.set('hero_title', params[:hero_title]) if params[:hero_title].present?
    SiteContent.set('hero_description', params[:hero_description]) if params[:hero_description].present?
    
    redirect_to site_contents_path, notice: 'Hero content succesvol bijgewerkt.'
  end
end

