# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Actions::API::Base do
  subject(:action) { implementation.new }

  describe "#call" do
    context "with unique constraint error" do
      let :implementation do
        Class.new described_class do
          def handle(*)
            fail ROM::SQL::UniqueConstraintError, StandardError.new(<<~CONTENT)
              PG::UniqueViolation: ERROR:  duplicate key value violates unique
              constraint "model_label_key"
              DETAIL:  Key (label)=(Demo) already exists.
            CONTENT
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
        Class.new described_class do
          def handle(*)
            message = <<~CONTENT
              "other" (String) has invalid type for :mode violates constraints
              (included_in?(["automatic", "manual"], "other") failed)
            CONTENT

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
        Class.new described_class do
          def handle(*)
            fail ROM::SQL::ForeignKeyConstraintError, StandardError.new(<<~CONTENT)
              PG::ForeignKeyViolation: ERROR:  insert or update on table "playlist_item"
              violates foreign key constraint "playlist_item_playlist_id_fkey"
              DETAIL:  Key (playlist_id)=(29) is not present in table "playlist"
            CONTENT
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
        Class.new described_class do
          def handle(*)
            fail ROM::SQL::DatabaseError,
                 StandardError.new("PG::NumericValueOutOfRange: ERROR:  integer out of range")
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
