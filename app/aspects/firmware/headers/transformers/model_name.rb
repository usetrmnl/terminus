# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Firmware
      module Headers
        module Transformers
          # Transforms a model name to a name that looked up in the database.
          class ModelName
            include Deps[:logger]

            include Initable[
              key: :HTTP_MODEL,
              map: {
                "og" => "og_plus",
                "og_gen2" => "og_plus",
                "paper_s3" => "m5_paper_s3",
                "reterminal_e1001" => "seeed_e1001",
                "reterminal_e1002" => "seeed_e1002",
                "reterminal_e1003" => "seeed_e1003",
                "seeed_esp32c3" => "seeed_e1001",
                "seeed_esp32s3" => "seeed_e1002",
                "x" => "v2",
                "xiao_epaper_display" => "og_plus",
                "xteink_x4" => "xteink_x4"
              },
              fallback: "og_plus"
            ]

            include Dry::Monads[:result]

            def call headers
              rename(headers[key]).bind { |value| Success headers.merge!(key => value) }
            end

            private

            def rename original
              value = String map[original]

              return Success value unless value.empty?

              logger.debug do
                "Unknown name when transforming #{key} header: #{original.inspect}. " \
                "Using fallback: #{fallback}."
              end

              Success fallback
            end
          end
        end
      end
    end
  end
end
