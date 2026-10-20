# frozen_string_literal: true

require "csv"
require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Devices
      # Bulk imports devices.
      class Importer
        include Deps[
          "aspects.devices.provisioner",
          contract: "contracts.devices.imports.bulk",
          model_repository: "repositories.model",
          playlist_repository: "repositories.playlist"
        ]
        include Initable[parser: CSV]
        include Dry::Monads[:result]

        HEADERS = {
          "Label" => :label,
          "Model Name" => :model_name,
          "Playlist Name" => :playlist_name,
          "MAC Address" => :mac_address,
          "API Key" => :api_key,
          "Refresh Rate" => :refresh_rate,
          "Image Timeout" => :image_timeout,
          "Firmware Update" => :firmware_update,
          "Display Compatibility" => :device_compatibility,
          "Display Profile" => :display_profile,
          "Command" => :command,
          "Touch Bar" => :touch_bar,
          "Sleep Start At" => :sleep_start_at,
          "Sleep Stop At" => :sleep_stop_at
        }.freeze

        def initialize(headers: HEADERS, **)
          @headers = headers
          super(**)
        end

        def call content
          contract.call(rows: parse(content))
                  .to_monad
                  .fmap { process it.to_h.fetch(:rows) }
                  .bind { it[:errors].empty? ? Success(it) : Failure(it) }
        end

        private

        attr_reader :headers

        def parse content
          parser.instance(content, headers: true, header_converters: proc { headers[it] })
                .to_a
                .map(&:to_h)
        end

        # :reek:FeatureEnvy
        def process rows, partition: Hash.new { |nascence, lacuna| nascence[lacuna] = [] }
          rows.each.with_object partition do |row, all|
            case provision row
              in Success(record) then all[:devices].append record
              in Failure(result) then all[:errors].append result
            end
          end
        end

        def provision row
          build_ids(row).bind { provisioner.call(**it, **row) }
        end

        # :reek:TooManyStatements
        def build_ids row
          model_id = nil
          model_name = row.delete :model_name

          find_model(model_name).fmap { |model| model_id = model.id }
                                .bind { find_playlist_id row.delete(:playlist_name) }
                                .fmap { {model_id:, playlist_id: it} }
        end

        def find_model name
          model_repository.find_by(name:).then do |model|
            model ? Success(model) : Failure("Unable to find model by name: #{name.inspect}.")
          end
        end

        def find_playlist_id name
          return Success nil unless name

          playlist_repository.find_by(name:).then do |playlist|
            return Success playlist.id if playlist

            Failure "Unable to find playlist by name: #{name.inspect}."
          end
        end
      end
    end
  end
end
