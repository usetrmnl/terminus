# frozen_string_literal: true

require "rfc/api/problem"

require_relative "../../aspects/errors/problem"

module Terminus
  module Actions
    module API
      # The base action.
      class Base < Action
        config.formats.accept :json
        handle_exception Dry::Types::SchemaError => :detail_enum,
                         ROM::SQL::DatabaseError => :detail_out_of_range,
                         ROM::SQL::ForeignKeyConstraintError => :detail_foreign_key,
                         ROM::SQL::UniqueConstraintError => :detail_duplicate

        using Refines::Actions::Response

        def initialize(problem: RFC::API::Problem, problem_detail: Aspects::Errors::Problem, **)
          @problem = problem
          @problem_detail = problem_detail
          super(**)
        end

        protected

        attr_reader :problem

        # simplecov:disable
        def verify_csrf_token?(*) = false
        # simplecov:enable

        private

        attr_reader :problem_detail

        def detail_duplicate request, response, error
          payload = problem_detail.duplicate error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def detail_enum request, response, error
          payload = problem_detail.enum error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def detail_foreign_key request, response, error
          payload = problem_detail.foreign_key error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def detail_out_of_range request, response, error
          payload = problem_detail.out_of_range error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end
      end
    end
  end
end
