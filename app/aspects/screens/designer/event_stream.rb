# auto_register: false
# frozen_string_literal: true

require "initable"

module Terminus
  module Aspects
    module Screens
      module Designer
        # Renders device preview image event streams.
        class EventStream
          include Deps[
            :logger,
            repository: "repositories.screen",
            view: "views.designer.event_stream"
          ]
          include Initable[%i[req name], kernel: Kernel]

          def call stream
            indefinitely_write_to stream
          rescue Errno::EPIPE, Errno::ECONNRESET, IOError
            logger.debug { "Event stream disconnected." }
          ensure
            stream.close
          end

          private

          def indefinitely_write_to stream
            kernel.loop do
              stream.write <<~CONTENT
                event: preview
                #{render_data}

              CONTENT

              kernel.sleep 1
            end
          end

          def render_data
            repository.find_by(name:).then do |screen|
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
end
