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

        def fetch name = nil
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
          model_repository.where(name: model_map[name]).map do |model|
            firmware = repository.where_with_model(name: model.name, version:).first

            return firmware if firmware

            attach model, version, response
          end
        end

        def attach model, version, response
          struct.new.then do |instance|
            instance.upload StringIO.new(response), metadata: {"filename" => "#{version}.bin"}
            instance.valid? ? create(model, version, instance) : instance.errors
          end
        end

        def create model, version, struct
          firmware = repository.create version:, attachment_data: struct.attachment_attributes

          repository.update_with_models firmware.id, Core::EMPTY_HASH, [model.id]
          firmware
        end
      end
    end
  end
end
