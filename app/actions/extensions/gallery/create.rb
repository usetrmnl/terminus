# frozen_string_literal: true

require "refinements/array"

module Terminus
  module Actions
    module Extensions
      module Gallery
        # The create action.
        class Create < Action
          include Deps["aspects.extensions.importers.remote.creator"]

          using Refinements::Array

          params { required(:id).filled :integer }

          def handle request, response
            flash = response.flash

            case import request.params
              in Success(extension)
                flash[:notice] = notice extension
                response.redirect_to routes.path(:extensions_gallery)
              in Failure(Dry::Schema::Result => result) then render_schema_errors result, response
              in Failure(message) then render_error message, response
            end
          end

          private

          # :reek:FeatureEnvy
          def notice extension
            path = routes.path :extension_edit, id: extension.id
            %(<a href="#{path}">#{extension.label}</a> extension imported!).html_safe
          end

          def import parameters
            contract.call(parameters.to_h)
                    .to_monad
                    .bind { |parameters| creator.call parameters[:id] }
          end

          # :reek:FeatureEnvy
          def render_schema_errors result, response
            result.errors
                  .to_h
                  .map { |key, value| "#{key} #{value.to_sentence}." }
                  .join("\n")
                  .then { |content| response.flash[:alert] = content }

            response.redirect_to routes.path(:extensions_gallery)
          end

          # :reek:FeatureEnvy
          def render_error message, response
            response.flash[:alert] = message
            response.redirect_to routes.path(:extensions_gallery)
          end
        end
      end
    end
  end
end
