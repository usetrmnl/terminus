# frozen_string_literal: true

require "petail"

require_relative "../../aspects/errors/problem"

module Terminus
  module Actions
    module API
      # The base action.
      class Base < Action
        config.formats.accept :json
        handle_exception Dry::Types::SchemaError => :detail_enum,
                         ROM::SQL::UniqueConstraintError => :detail_duplicate,
                         ROM::SQL::ForeignKeyConstraintError => :detail_foreign_key

        using Refines::Actions::Response

        def initialize(petail: Petail, problem: Aspects::Errors::Problem, **)
          @petail = petail
          @problem = problem
          super(**)
        end

        protected

        attr_reader :petail

        # simplecov:disable
        def verify_csrf_token?(*) = false
        # simplecov:enable

        private

        attr_reader :problem

        def detail_duplicate request, response, error
          payload = problem.duplicate error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def detail_enum request, response, error
          payload = problem.enum error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def detail_foreign_key request, response, error
          payload = problem.foreign_key error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end
      end
    end
  end
end
