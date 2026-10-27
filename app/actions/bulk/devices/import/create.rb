# frozen_string_literal: true

require "core"

module Terminus
  module Actions
    module Bulk
      module Devices
        module Import
          # The create action.
          # :reek:DataClump
          class Create < Action
            include Deps["aspects.devices.importer", "aspects.errors.detailer"]

            contract Contracts::Devices::Imports::Source

            def initialize(
              downloader: Aspects::Downloader.new(allowed_domains: Core::EMPTY_ARRAY),
              **
            )
              @downloader = downloader
              super(**)
            end

            def handle request, response
              parameters = request.params

              if parameters.valid?
                process parameters, response
              else
                response.flash[:alert] = detailer.call parameters.errors.to_h
                response.redirect_to routes.path(:devices)
              end
            end

            private

            attr_reader :downloader

            def process parameters, response
              case parameters
                in {devices: {uri: String}} then handle_uri parameters, response
                in {devices: {attachment:}} then handle_attachment parameters, response
              end
            end

            # :reek:TooManyStatements
            # rubocop:todo-next Metrics/AbcSize
            def handle_uri parameters, response
              uri = parameters.to_h.dig :devices, :uri
              flash = response.flash

              result = downloader.call(uri).bind { importer.call it.to_s }

              case result
                in Success then flash[:notice] = translate ".notice"
                in Failure(HTTP::Response) then flash[:alert] = translate ".download_error"
                in Failure(failure) then flash[:alert] = detailer.call failure.errors.to_h
              end

              response.redirect_to routes.path(:devices)
            end

            def handle_attachment parameters, response
              path = parameters.to_h.dig :devices, :attachment, :tempfile
              flash = response.flash

              case importer.call path.read
                in Success then flash[:notice] = translate ".notice"
                in Failure(result) then flash[:alert] = detailer.call result.errors.to_h
              end

              response.redirect_to routes.path(:devices)
            end
          end
        end
      end
    end
  end
end
