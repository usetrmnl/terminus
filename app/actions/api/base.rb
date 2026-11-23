# frozen_string_literal: true

require "rfc/api/problem"

require_relative "../../aspects/errors/problem"

module Terminus
  module Actions
    module API
      # The base action.
      class Base < Action
        config.formats.accept :json

        using Refines::Actions::Response

        def initialize(problem: RFC::API::Problem, problem_detail: Aspects::Errors::Problem, **)
          @problem = problem
          @problem_detail = problem_detail
          super(**)
        end

        protected

        attr_reader :problem, :problem_detail

        def verify_csrf_token?(*) = false

        def render_duplicate request, response, error
          payload = problem_detail.duplicate error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def render_enum request, response, error
          payload = problem_detail.enum error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def render_foreign_key request, response, error
          payload = problem_detail.foreign_key error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end

        def render_out_of_range request, response, error
          payload = problem_detail.out_of_range error.message, request.path
          response.with body: payload.to_json, format: :problem_details, status: payload.status
        end
      end
    end
  end
end
