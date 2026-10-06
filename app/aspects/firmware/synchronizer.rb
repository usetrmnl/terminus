# frozen_string_literal: true

module Terminus
  module Aspects
    module Firmware
      # A firmware attachment synchronizer with Core server.
      class Synchronizer
        include Deps[
          :trmnl_api,
          "aspects.downloader",
          "aspects.firmware.creator",
          repository: "repositories.firmware",
          model_repository: "repositories.model"
        ]
        include Dry::Monads[:result]

        MODEL_MAP = {trmnl_bwry: ["og_bwry"], trmnl_og: %w[og_png og_plus], trmnl_x: ["v2"]}.freeze

        def initialize(model_map: MODEL_MAP, struct: Structs::Firmware, **)
          @model_map = model_map
          @struct = struct
          super(**)
        end

        def call
          model_map.keys
                   .flat_map { fetch it }
                   .then do |collection|
                     if collection.empty? then Success []
                     elsif collection.all? struct then Success collection
                     else Failure(collection.grep_v(struct))
                     end
                   end
        end

        private

        attr_reader :model_map, :struct

        def fetch name
          result = trmnl_api.firmware_latest model_name: name

          case result
            in Success(payload) then download name, payload
            in Failure(errors) then errors
          end
        end

        def download name, payload
          case downloader.call payload.url
            in Success(response) then find_or_create response, name, payload.version
            in Failure(payload) then payload
          end
        end

        def find_or_create response, name, version
          model_names = model_map[name]
          models = model_repository.where name: model_names
          firmware = repository.where(name: model_names, version:).first

          return firmware if firmware

          attach response, version, models
        end

        def attach response, version, models
          struct.new.then do |instance|
            instance.upload StringIO.new(response), metadata: {"filename" => "#{version}.bin"}
            instance.valid? ? create(version, instance, models) : instance.errors
          end
        end

        def create version, struct, models
          repository.create_with_models(
            {version:, attachment_data: struct.attachment_attributes},
            models.map(&:id)
          )
        end
      end
    end
  end
end
