# frozen_string_literal: true

require "hanami"
require "rfc/api/problem"
require "terminus/csp_appender"

require_relative "initializers/universal_logger_patch"

module Terminus
  # The application base configuration.
  class App < Hanami::App
    RubyVM::YJIT.enable if defined? RubyVM::YJIT
    Dry::Schema.load_extensions :monads
    Dry::Validation.load_extensions :monads

    config.i18n.fallbacks = true
    config.inflections { it.acronym "CSP", "DEFAULTS", "HTML", "IP", "MAC", "QR", "URI" }

    config.actions.content_security_policy.then do |csp|
      csp[:manifest_src] = "'self'"
      csp[:script_src] += " 'unsafe-eval' 'unsafe-inline'"
    end

    Hanami.app
          .config
          .actions
          .content_security_policy
          .instance_variable_get(:@policy)
          .then { it.replace CSPAppender.new.call(it) }

    config.actions.formats.register :problem_details, RFC::API::Problem::MEDIA_TYPE_JSON

    # rubocop:todo-next Layout/FirstArrayElementLineBreak
    config.actions.sessions = :cookie,
                              {
                                key: "terminus.session",
                                secret: settings.app_secret,
                                expire_after: 3_600 # 1 hour.
                              }
  end
end
