# frozen_string_literal: true

require "core"

module Terminus
  module Aspects
    module Extensions
      # A specialized URI builder based template and data to produce an array of fully formed URIs.
      class URIBuilder
        include Deps[renderer: "liquid.basic"]

        def call(template, data = Core::EMPTY_HASH) = renderer.call(template, data).split
      end
    end
  end
end
