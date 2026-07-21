# frozen_string_literal: true

require "hanami"
require "petail"

require_relative "initializers/rack_attack"
require_relative "initializers/universal_logger_patch"

module Terminus
  # The application base configuration.
  class App < Hanami::App
    RubyVM::YJIT.enable if defined? RubyVM::YJIT
    Dry::Schema.load_extensions :monads
    Dry::Validation.load_extensions :monads

    config.inflections { it.acronym "DEFAULTS", "HTML", "IP", "MAC", "URI" }

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
                                expire_after: 3_600, # 1 hour.
                                # Default-false so upstream's supported plain-HTTP deployments
                                # keep working (a Secure cookie would be dropped over HTTP);
                                # TLS deployments set SESSION_COOKIE_SECURE=true.
                                secure: settings.session_cookie_secure,
                                # Lax (not Strict) so the session/state cookie survives the
                                # top-level redirect back from the OIDC provider's callback.
                                same_site: :lax
                              }
    # rubocop:enable Layout/FirstArrayElementLineBreak

    config.middleware.use Rack::Attack
  end
end
