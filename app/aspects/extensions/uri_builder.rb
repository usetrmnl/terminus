# frozen_string_literal: true

require "dry/core"

module Terminus
  module Aspects
    module Extensions
      # A specialized URI builder based template and data to produce an array of fully formed URIs.
      class URIBuilder
        include Deps[renderer: "liquid.raw"]

        def call(template, data = Dry::Core::EMPTY_HASH) = renderer.call(template, data).split
      end
    end
  end
end
