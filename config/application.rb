require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

# If you have a Gemfile, require the default gems, the ones in the
# current environment and also include :assets gems if in development
# or test environments.
#Bundler.require *Rails.groups(assets: %w(development test)) if defined?(Bundler)
Bundler.require *Rails.groups(:assets) if defined?(Bundler)

module Merchants
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)

    config.time_zone = 'Buenos Aires'

    config.i18n.default_locale = :es

    config.encoding = "utf-8"

    config.filter_parameters += [:password]

    config.assets.enabled = true
    config.assets.version = '1.0'

  end
end
