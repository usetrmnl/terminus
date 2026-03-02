# frozen_string_literal: true

require "hanami"
require "petail"

require_relative "initializers/rack_attack"
require_relative "initializers/rack_logger_patch"
require_relative "initializers/sql_logger_patch"

module Terminus
  # The application base configuration.
  class App < Hanami::App
    # :nocov:
    RubyVM::YJIT.enable if defined? RubyVM::YJIT
    # :nocov:
    Dry::Schema.load_extensions :monads
    Dry::Validation.load_extensions :monads

    prepare_container do |container|
      container.config.component_dirs.dir "app" do |dir|
        dir.memoize = -> component { component.key.start_with? "repositories." }
      end
    end

    config.inflections { it.acronym "DEFAULTS", "HTML", "IP", "URI", "URIs" }

    config.actions.content_security_policy.then do |csp|
      csp[:connect_src] += " https://trmnl.com"
      csp[:font_src] += " https://trmnl.com"
      csp[:manifest_src] = "'self'"
      csp[:script_src] += " 'unsafe-eval' 'unsafe-inline' https://trmnl.com"
    end

    config.actions.formats.register :problem_details, Petail::MEDIA_TYPE_JSON

    # rubocop:todo Layout/FirstArrayElementLineBreak
    config.actions.sessions = :cookie,
                              {
                                key: "terminus.session",
                                secret: settings.app_secret,
                                expire_after: 3_600 # 1 hour.
                              }
    # rubocop:enable Layout/FirstArrayElementLineBreak

    config.middleware.use Rack::Attack
    config.middleware.use Rack::Deflater
    config.middleware.use :body_parser, :json
  end
end
