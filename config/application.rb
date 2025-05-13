require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Laad .env-bestanden alleen in development en test, niet in production
if %w[development test].include?(Rails.env)
  require 'dotenv'
  Dotenv.load('.env')
end

# Laad .env-variabelen in productieomgeving
require 'dotenv-rails'
Dotenv::Railtie.load if Rails.env.production?

module HardlopenMetvirgilNl
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Autoload lib, maar negeer submappen die geen .rb bestanden bevatten
    config.autoload_lib(ignore: %w(assets tasks))

    # Algemene configuratie hier plaatsen indien nodig:
    #
    # config.time_zone = "Amsterdam"
    # config.eager_load_paths << Rails.root.join("extras")

    # Voor performance in productie eventueel Dotenv uitzetten
    # Dotenv wordt hierboven alleen in development/test geladen
  end
end