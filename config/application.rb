# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# rubocop:disable Lint/Debugger
require 'debug/open_nonstop' if defined?(Rails::Server) && Rails.env.development?
# rubocop:enable Lint/Debugger

Bundler.require(*Rails.groups)

# rubocop:disable Style/ClassAndModuleChildren
module TurboMorphing
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w[assets tasks])
  end
end
# rubocop:enable Style/ClassAndModuleChildren
