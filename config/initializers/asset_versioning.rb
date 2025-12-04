# Professional Asset Versioning Strategy
#
# This ensures browser always loads fresh HTML by appending version to asset tags
# Industry standard solution for cache busting

Rails.application.config.after_initialize do
  # Generate version based on app restart time
  APP_VERSION = Time.current.to_i.to_s
  
  # Make available to views
  ActionView::Base.class_eval do
    def app_version
      APP_VERSION
    end
  end
end

