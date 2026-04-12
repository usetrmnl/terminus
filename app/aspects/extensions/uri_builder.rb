# frozen_string_literal: true

require "dry/core"

module Terminus
  module Aspects
    module Extensions
      # Builds URI array from template and data by splitting on new lines.
      class URIBuilder
        include Deps[renderer: "liquid.default"]

        def call(template, data = Dry::Core::EMPTY_HASH) = renderer.call(template, data).split
      end
    end
  end
end
