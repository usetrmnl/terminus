# frozen_string_literal: true

require "refinements/hash"

module Terminus
  module Actions
    module Extensions
      # The update action.
      class Update < Action
        include Deps["aspects.jobs.schedule", repository: "repositories.extension"]

        using Refinements::Hash

        contract Contracts::Extensions::Update

        def handle request, response
          parameters = request.params
          extension = repository.find parameters[:id]

          halt :unprocessable_content unless extension

          if parameters.valid?
            render extension, parameters, response
          else
            error extension, parameters, response
          end
        end

        private

        def render extension, parameters, response
          update extension, parameters[:extension]

          response.flash[:notice] = "Changes saved."
          response.redirect_to routes.path(:extension_edit, id: extension.id)
        end

        # rubocop:disable Metrics/AbcSize
        def update extension, attributes
          attributes = attributes.dup
          id = extension.id
          model_ids, device_ids = attributes.values_at :model_ids, :device_ids
          ha_attributes = extract_home_assistant_attributes attributes

          attributes[:kind] == "home_assistant" &&
            repository.update_with_home_assistant(id, attributes, ha_attributes)

          repository.update_with_devices id, attributes, Array(device_ids)

          extension = repository.update_with_models id, attributes, Array(model_ids)

          schedule.upsert(*extension.to_schedule, old_name: extension.screen_name)
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

        def error extension, parameters, response
          fields = parameters[:extension].transform_with!(
            start_at: -> value { value.strftime("%Y-%m-%dT%H:%M:%S") }
          )

          response.render view, extension:, fields:, errors: parameters.errors[:extension]
        end
      end
    end
  end
end
