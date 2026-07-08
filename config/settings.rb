# frozen_string_literal: true

require "terminus/types"

module Terminus
  # The application base settings.
  class Settings < Hanami::Settings
    setting :api_access_token_period, constructor: Types::Params::Integer, default: 1_800
    setting :app_secret,
            constructor: Types::Params::String.constrained(filled: true, min_size: 64),
            default: SecureRandom.hex(40)
    setting :api_uri, constructor: Types::Params::String.constrained(filled: true)
    setting :ferrum_default_timeout, constructor: Types::Params::Integer, default: 30
    setting :ferrum_process_timeout, constructor: Types::Params::Integer, default: 15
    setting :ferrum_javascript_errors, constructor: Types::Params::Bool, default: true
    setting :ferrum_url, constructor: Types::Params::String, default: ""
    setting :fonts_root,
            constructor: Terminus::Types::Pathname,
            default: Hanami.app.root.join("public/fonts")
    setting :git_latest_sha,
            constructor: Types::Params::String,
            default: `git rev-parse --short HEAD`.strip
    setting :git_tag,
            constructor: Types::Params::String,
            default: `git tag --list --sort=taggerdate | tail -n 1`.strip
    setting :firmware_synchronizer, constructor: Types::Params::Bool, default: true
    setting :font_synchronizer, constructor: Types::Params::Bool, default: true
    setting :http_timeout_connect,
            constructor: Types::Params::Integer.constrained(gt: 0),
            default: 2
    setting :http_timeout_read, constructor: Types::Params::Integer.constrained(gt: 0), default: 10
    setting :http_timeout_write, constructor: Types::Params::Integer.constrained(gt: 0), default: 10
    setting :keyvalue_url, constructor: Types::Params::String.constrained(filled: true)
    setting :model_synchronizer, constructor: Types::Params::Bool, default: true
    setting :sensors_path,
            constructor: Terminus::Types::Pathname,
            default: Hanami.app.root.join("public/sensors.json")
    setting :screen_synchronizer, constructor: Types::Params::Bool, default: true
    setting :session_inactivity_limit, constructor: Types::Params::Integer, default: 1_800
    setting :session_lifetime_limit, constructor: Types::Params::Integer, default: 86_400
    setting :session_expiration_enabled, constructor: Types::Params::Bool, default: true
  end
end
