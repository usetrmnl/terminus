# frozen_string_literal: true

require "core"

module Terminus
  # Appends to an existing Content Security Policy (CSP) with given URIs.
  class CSPAppender
    ALLOWED_KEYS = %i[
      child_src
      connect_src
      font_src
      frame_src
      img_src
      media_src
      script_src
      style_src
    ].freeze

    def initialize allowed_keys: ALLOWED_KEYS, default_uri: "https://trmnl.com", delimiter: " "
      @allowed_keys = allowed_keys
      @default_uri = default_uri
      @delimiter = delimiter
    end

    def call policy, uris = Core::EMPTY_ARRAY
      suffix = uris.join delimiter

      policy.each.with_object({}) do |(key, value), all|
        all[key] = maybe_revalue key, value, suffix
      end
    end

    private

    attr_reader :allowed_keys, :default_uri, :delimiter

    def maybe_revalue key, value, suffix
      return value unless allowed_keys.include? key

      "#{value}#{delimiter}#{default_uri}#{delimiter}#{suffix}".strip
    end
  end
end
