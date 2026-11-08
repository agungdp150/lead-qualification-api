require_relative "boot"
require "rails"
require "action_controller/railtie"
require "securerandom"

module LeadScorer
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true
    config.eager_load = ENV["RAILS_ENV"] == "production"
    # Stateless API: no cookies or persisted signatures depend on this key.
    config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") { SecureRandom.hex(64) }
    config.logger = ActiveSupport::Logger.new($stdout)
    config.log_level = :warn
    config.filter_parameters += [:conversation, :text, :authorization, :api_key]
    config.hosts.clear
    config.consider_all_requests_local = false
    config.action_dispatch.show_exceptions = :none
  end
end
