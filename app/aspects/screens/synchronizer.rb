# frozen_string_literal: true

require "core"
require "dry/monads"
require "initable"
require "rack"
require "refinements/pathname"
require "refinements/string"

module Terminus
  module Aspects
    module Screens
      # A screen attachment synchronizer with Core server.
      # :reek:DataClump
      class Synchronizer
        include Deps[
          :logger,
          "aspects.downloader",
          "aspects.screens.compressor",
          model_repository: "repositories.model",
          screen_repository: "repositories.screen"
        ]

        include Initable[struct: proc { Terminus::Structs::Screen.new }, rack: Rack::Utils]
        include Dry::Monads[:result]

        using Refinements::Pathname
        using Refinements::String

        PATTERN = /(-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z|-\d{10})/

        def initialize(pattern: PATTERN, **)
          @pattern = pattern
          super(**)
        end

        def call display
          url = display.image_url
          pathname = pathname_from display.filename, url

          return Failure "Invalid URL: #{url}." if pathname.extname == "."

          downloader.call(url).bind { |response| upsert pathname, response, find_screen(pathname) }
        end

        private

        attr_reader :struct, :pattern, :rack

        def pathname_from file_name, url
          Pathname "#{file_name.gsub pattern, Core::EMPTY_STRING}.#{type_for url}"
        end

        def type_for uri
          rack.parse_query(uri)
              .fetch("response-content-type", Core::EMPTY_STRING)
              .sub("image/", Core::EMPTY_STRING)
        end

        def find_screen pathname
          screen_repository.find_by(name: pathname.name.to_s).tap { it.image_destroy if it }
        end

        def upsert pathname, response, screen
          process_download(pathname, response).bind do |struct|
            if screen
              update screen, struct
            else
              create pathname.name.to_s, struct, find_model(struct)
            end
          end
        end

        def process_download pathname, response
          Pathname.mktmpdir { |root| upload root, pathname, response }
          struct.valid? ? Success(struct) : Failure(struct.errors)
        end

        def upload work_dir, pathname, response
          input_path = work_dir.join(pathname).write(response)
          output_path = compressor.call(input_path).value!

          output_path.open do |io|
            struct.upload io, metadata: {"filename" => output_path.basename}
          end
        end

        def update screen, struct
          Success screen_repository.update screen.id, image_data: struct.image_attributes
        end

        def find_model struct
          metadata = struct.image_attributes.fetch :metadata, Core::EMPTY_HASH
          model_repository.find_by kind: "trmnl", **metadata.slice(:bit_depth, :width, :height)
        end

        def create name, struct, model
          return log_failure unless model

          Success(
            screen_repository.create(
              model_id: model.id,
              name:,
              label: name.sub(/\..+$/, "").titleize,
              image_data: struct.image_attributes
            )
          )
        end

        def log_failure
          logger.error { "Unable to find model for screen." }
          Failure()
        end
      end
    end
  end
end
