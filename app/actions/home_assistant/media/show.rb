# frozen_string_literal: true

module Terminus
  module Actions
    module HomeAssistant
      module Media
        # Proxies Home Assistant media and local image paths through Terminus.
        class Show < Action
          include Deps[
            repository: "repositories.home_assistant_connection",
            client: "aspects.home_assistant.client",
            logger: "logger"
          ]

          params { required(:path).filled :string }

          def handle request, response
            path = request.params[:path].to_s.strip
            return bad_request response, "Invalid Home Assistant media path." unless safe_path? path

            connection = repository.current
            result = client.fetch connection, path

            return handle_failure response, result.failure if result.failure?

            render_upstream response, result.value!
          end

          protected

          # Media proxy is used by rendered screen images and must be reachable
          # without an authenticated web session.
          def authorize(*) = nil

          private

          def safe_path? path
            path.start_with? "/api/", "/local/"
          end

          def bad_gateway response
            response.status = 502
            response.body = ""
          end

          def handle_failure response, message
            logger.warn "Home Assistant media proxy failure: #{message}"
            bad_gateway response
          end

          def render_upstream response, upstream
            response.status = 200
            response.headers["Content-Type"] =
              upstream.headers["Content-Type"] || "application/octet-stream"
            response.headers["Cache-Control"] = "public, max-age=60"
            response.body = upstream.to_s
          end

          def bad_request response, message
            response.status = 400
            response.body = message
          end
        end
      end
    end
  end
end
