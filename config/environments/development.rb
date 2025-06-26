require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Code wordt herladen bij elke request.
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  # Assets direct serveren, niet precompilen/cachen
  config.assets.debug = true
  config.assets.compile = true
  config.assets.digest = false
  config.assets.cache_store = :null_store
  config.public_file_server.enabled = true

  # Geen caching
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Log alles
  config.log_level = :debug

  # Mailer settings (optioneel, voor development)
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false

  # Andere standaard development settings
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end 