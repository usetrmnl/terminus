# frozen_string_literal: true

require "refinements/pathname"

module Terminus
  module Actions
    module API
      module Firmware
        # The patch action.
        class Patch < Base
          include Deps["aspects.downloader", repository: "repositories.firmware"]
          include Initable[serializer: Serializers::Firmware]

          using Refines::Actions::Response
          using Refinements::Pathname

          params do
            required(:id).filled :integer

            required(:firmware).filled :hash do
              optional(:version).filled Types::Version
              optional(:kind).filled :string
              optional(:uri).filled :string
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              process(*parameters.to_h.values_at(:id, :firmware), response)
            else
              unprocessable_content parameters, response
            end
          end

          private

          def process id, parameters, response
            uri = parameters.delete :uri
            record = repository.update id, parameters

            return response.with body: {data: serializer.new(record).to_h}.to_json unless uri

            download uri, record, response
          end

          def download uri, record, response
            downloader.call(uri)
                      .either -> payload { replace record, payload.body.to_s, response },
                              proc { unprocessable_download uri, response }
          end

          # :reek:FeatureEnvy
          def replace record, content, response
            Pathname.mktmpdir do |root|
              root.join("#{record.version}.bin").write(content).open { record.replace it }
            end

            update = repository.update record.id, attachment_data: record.attachment_attributes

            response.with body: {data: serializer.new(update).to_h}.to_json
          end

          def unprocessable_download uri, response
            response.with_details problem[
              type: "/problem_details#firmware_payload",
              status: :unprocessable_content,
              detail: "Invalid URI: #{uri}.",
              instance: "/api/firmware"
            ]
          end

          def unprocessable_content parameters, response
            response.with_details problem[
              type: "/problem_details#firmware_payload",
              status: :unprocessable_content,
              detail: translate("api.shared.errors.validation"),
              instance: "/api/firmware",
              extensions: {errors: parameters.errors.to_h}
            ]
          end
        end
      end
    end
  end
end
