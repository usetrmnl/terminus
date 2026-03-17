# frozen_string_literal: true

require "terminus/types"

module Terminus
  # The application base settings.
  class Settings < Hanami::Settings
    setting :api_access_token_period, constructor: Types::Params::Integer, default: 1_800
    setting :api_uri, constructor: Types::Params::String.constrained(filled: true)
    setting :app_secret,
            constructor: Types::Params::String.constrained(filled: true, min_size: 64),
            default: SecureRandom.hex(40)
    setting :browser, constructor: Terminus::Types::Browser, default: "{}"
    setting :color_maps_root,
            constructor: Terminus::Types::Pathname,
            default: Hanami.app.root.join("public/assets/color_maps")
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
    setting :keyvalue_url, constructor: Types::Params::String.constrained(filled: true)
    setting :model_synchronizer, constructor: Types::Params::Bool, default: true
    setting :sensors_path,
            constructor: Terminus::Types::Pathname,
            default: Hanami.app.root.join("public/sensors.json")
    setting :screen_synchronizer, constructor: Types::Params::Bool, default: true
  end
end
