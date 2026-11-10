# frozen_string_literal: true

require "core"

module Terminus
  module Chromium
    # Models configuration.
    Model = Data.define :browser_options, :maximums do
      def initialize browser_options: Core::EMPTY_HASH, maximums: Core::EMPTY_HASH
        super
      end

      def merge_options(other = Core::EMPTY_HASH) = other.merge(browser_options:)

      def maximum_renders = maximums.fetch "renders"

      def maximum_recoveries = maximums.fetch "recoveries"
    end
  end
end
