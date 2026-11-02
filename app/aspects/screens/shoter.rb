# frozen_string_literal: true

require "dry/monads"

module Terminus
  module Aspects
    module Screens
      # Saves web page as screenshot.
      class Shoter
        include Deps[:chromium]
        include Dry::Monads[:result]

        def call content, output_path, **viewport
          render(content, output_path, viewport).fmap { output_path }
        end

        def render content, output_path, viewport
          chromium.call do |page|
            page.content = content
            page.set_viewport(**viewport)
            page.network.wait_for_idle duration: 5
            page.screenshot path: output_path.to_s
          end
        end
      end
    end
  end
end
