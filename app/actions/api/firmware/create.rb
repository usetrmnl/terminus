# frozen_string_literal: true

require "refinements/pathname"

module Terminus
  module Actions
    module API
      module Firmware
        # The create action.
        class Create < Base
          include Deps["aspects.downloader", repository: "repositories.firmware"]
          include Initable[serializer: Serializers::Firmware]

          using Refines::Actions::Response
          using Refinements::Pathname

          params do
            required(:firmware).filled :hash do
              required(:version).filled Types::Version
              required(:kind).filled :string
              required(:uri).filled :string
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              process parameters[:firmware], response
            else
              unprocessable_content parameters, response
            end
          end

          private

          def process parameters, response
            uri = parameters.delete :uri
            record = repository.create parameters

            downloader.call(uri)
                      .either -> http_response { upload record, http_response.body.to_s, response },
                              proc { unprocessable_download uri, response }
          end

          # :reek:FeatureEnvy
          # :reek:TooManyStatements
          def upload record, content, response
            Pathname.mktmpdir do |root|
              root.join("#{record.version}.bin").write(content).open { record.upload it }
            end

            update = repository.update record.id, attachment_data: record.attachment_attributes

            response.body = {data: serializer.new(update).to_h}.to_json
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
