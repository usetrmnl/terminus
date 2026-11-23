# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::API::Base do
  subject(:action) { implementation.new }

  describe "#call" do
    let :errors do
      YAML.load_file SPEC_ROOT.join("support/fixtures/errors.yml"), symbolize_names: true
    end

    context "with CSRF capture" do
      let :implementation do
        Class.new described_class do
          protected

          def handle(*, response)
            response[:verify] = verify_csrf_token?
          end
        end
      end

      it "doesn't verify CSRF token" do
        response = implementation.new.call Hash.new
        expect(response.exposures[:verify]).to be(false)
      end
    end

    context "with unique constraint error" do
      let :implementation do
        message = errors.fetch :duplicate

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::UniqueConstraintError, StandardError.new(message)
          end
        end
      end

      it "answers problem details" do
        problem_detail = RFC::API::Problem.from_json Rack::MockRequest.new(action).get("").body
        expect(problem_detail).to have_attributes(type: /duplicate_value/)
      end
    end

    context "with enum error" do
      let :implementation do
        message = errors.fetch :enum

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail Dry::Types::SchemaError.new(:mode, "other", message)
          end
        end
      end

      it "answers problem details" do
        problem_detail = RFC::API::Problem.from_json Rack::MockRequest.new(action).get("").body
        expect(problem_detail).to have_attributes(type: /invalid_enum/)
      end
    end

    context "with foreign key error" do
      let :implementation do
        message = errors.fetch :foreign_key

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::ForeignKeyConstraintError, StandardError.new(message)
          end
        end
      end

      it "answers problem details" do
        problem_detail = RFC::API::Problem.from_json Rack::MockRequest.new(action).get("").body
        expect(problem_detail).to have_attributes(type: /invalid_foreign_key/)
      end
    end

    context "with numeric out of range error" do
      let :implementation do
        message = errors.fetch :out_of_range

        Class.new described_class do
          protected

          define_method :handle do |*|
            fail ROM::SQL::DatabaseError, StandardError.new(message)
          end
        end
      end

      it "answers problem details" do
        problem_detail = RFC::API::Problem.from_json Rack::MockRequest.new(action).get("").body
        expect(problem_detail).to have_attributes(type: /invalid_numeric/)
      end
    end
  end
end
