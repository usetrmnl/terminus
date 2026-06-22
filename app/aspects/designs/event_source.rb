# auto_register: false
# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Designs
      # Writes image updates to a stream.
      class EventSource
        include Deps[
          :logger,
          repository: "repositories.screen",
          view: "views.designs.event_stream"
        ]
        include Initable[%i[req id], kernel: Kernel]

        def call stream
          write stream
        rescue Errno::EPIPE, Errno::ECONNRESET, IOError
          logger.debug { "Event stream disconnected." }
        ensure
          stream.close
        end

        private

        def write stream
          kernel.loop do
            stream.write <<~CONTENT
              event: preview
              #{render_data}

            CONTENT

            kernel.sleep 0.5
          end
        end

        def render_data
          repository.find_by(id:).then do |screen|
            view.call(screen:, layout: false)
                .to_s
                .strip
                .each_line(chomp: true)
                .map { "data: #{it.strip}" }
                .join("\n")
          end
        end
      end
    end
  end
end
