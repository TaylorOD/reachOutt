Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"] == "true"
  config.active_storage.service = :local

  config.force_ssl = true
  # Hosting probes use HTTP internally. User requests still require HTTPS.
  config.ssl_options = { redirect: { exclude: ->(request) { ["/up", "/health/ready"].include?(request.path) } } }

  config.log_level = :info
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
  config.action_mailer.perform_caching = false
  config.action_mailer.raise_delivery_errors = true
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false
end
