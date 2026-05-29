# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      # The create action.
      class Create < Action
        include Deps[
          :htmx_layout,
          "aspects.jobs.schedule",
          repository: "repositories.extension",
          index_view: "views.extensions.index"
        ]

        using Refinements::Hash

        contract Contracts::Extensions::Create

        def handle request, response
          parameters = request.params

          if parameters.valid?
            save parameters
            response.render index_view,
                            extensions: repository.all,
                            layout: htmx_layout.call(request)
          else
            error response, parameters
          end
        end

        private

        # rubocop:disable Metrics/AbcSize
        def save parameters
          attributes = parameters[:extension].dup
          model_ids, device_ids = attributes.values_at :model_ids, :device_ids
          ha_attributes = extract_home_assistant_attributes attributes

          extension = if attributes[:kind] == "home_assistant"
                        repository.create_with_home_assistant attributes, ha_attributes
                      else
                        repository.create_with_models attributes, Array(model_ids)
                      end

          repository.update_with_devices extension.id, {}, Array(device_ids)
          schedule.upsert(*extension.to_schedule)
        end
        # rubocop:enable Metrics/AbcSize

        # rubocop:disable Metrics/MethodLength
        def extract_home_assistant_attributes attributes
          {
            source_mode: attributes.delete(:home_assistant_source_mode) || "entity",
            entity_ids: attributes.delete(:home_assistant_entity_ids) || [],
            endpoint_path: attributes.delete(:home_assistant_endpoint_path),
            attribute_map: attributes.delete(:home_assistant_attribute_map) || {},
            normalize_urls: if attributes.key? :home_assistant_normalize_urls
                              attributes.delete :home_assistant_normalize_urls
                            else
                              true
                            end
          }
        end
        # rubocop:enable Metrics/MethodLength

        def error response, parameters
          fields = parameters[:extension].transform_with!(
            start_at: -> value { value.strftime("%Y-%m-%dT%H:%M:%S") }
          )

          response.render view, fields:, errors: parameters.errors[:extension], layout: false
        end
      end
    end
  end
end
