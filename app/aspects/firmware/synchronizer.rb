# frozen_string_literal: true

module Terminus
  module Aspects
    module Firmware
      # A firmware attachment synchronizer with Core server.
      class Synchronizer
        include Deps[:trmnl_api, "aspects.downloader", repository: "repositories.firmware"]
        include Dry::Monads[:result]

        def initialize(struct: Structs::Firmware.new, **)
          @struct = struct
          super(**)
        end

        def call
          result = trmnl_api.firmware_latest

          case result
            in Success(payload) then download(payload).bind { attach it, payload.version }
            else result
          end
        end

        private

        attr_reader :struct

        def download(payload) = downloader.call payload.url

        def attach response, version
          record = repository.find_by(version:)

          return Success record if record

          struct.upload StringIO.new(response), metadata: {"filename" => "#{version}.bin"}
          struct.valid? ? Success(create(version, struct)) : Failure(struct.errors)
        end

        def create version, struct
          repository.create version: version, attachment_data: struct.attachment_attributes
        end
      end
    end
  end
end
