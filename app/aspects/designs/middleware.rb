# auto_register: false
# frozen_string_literal: true

require "initable"

require_relative "event_source"

module Terminus
  module Aspects
    module Designs
      # Streams Server Side Events (SSE) for device screen previews.
      class Middleware
        include Initable[
          %i[req application],
          %i[keyreq pattern],
          headers: {
            "Cache-Control" => "no-cache",
            "Content-Type" => "text/event-stream",
            "X-Accel-Buffering" => "no"
          },
          event_stream: EventSource
        ]

        def call environment
          request = Rack::Request.new environment
          path = request.path

          case path.match pattern
            in id: then response id, environment
            else application.call environment
          end
        end

        private

        def response id, environment
          environment["puma.mark_as_io_bound"].then { it.call if it }
          environment["rack.session.options"].then { it[:skip] = true if it }
          [200, headers, event_stream.new(id)]
        end
      end
    end
  end
end
