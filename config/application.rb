require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tenthousandhours
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Action Mailer
    config.action_mailer.default_url_options = { host: 'example.com' }
    config.action_mailer.delivery_method = :sendmail
    config.action_mailer.default_options = { from: "from@example.com" }
    
    # Default configuration for the Text Local service
    config.x.text_local_service.test    = true
    config.x.text_local_service.api_key = 'CHANGE_ME'
  end
end
