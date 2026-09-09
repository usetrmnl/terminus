# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Errors::Problem do
  subject(:problem_detail) { described_class }

  describe ".duplicate" do
    it "answers payload" do
      message = <<~CONTENT
        PG::UniqueViolation: ERROR:  duplicate key value violates unique
        constraint "model_label_key"
        DETAIL:  Key (label)=(Demo) already exists.
      CONTENT

      expect(problem_detail.duplicate(message, "/api/test")).to eq(
        RFC::API::Problem[
          type: "/problem_details#duplicate_value",
          status: :conflict,
          detail: %(Label must be unique. Please use a value other than "Demo".),
          instance: "/api/test"
        ]
      )
    end
  end

  describe ".enum" do
    it "answers payload" do
      message = <<~CONTENT
        "other" (String) has invalid type for :mode violates constraints
        (included_in?(["automatic", "manual"], "other") failed)
      CONTENT

      expect(problem_detail.enum(message, "/api/test")).to eq(
        RFC::API::Problem[
          type: "/problem_details#invalid_enum",
          status: :unprocessable_content,
          detail: %(Invalid value for mode: "other". Use: "automatic" or "manual".),
          instance: "/api/test"
        ]
      )
    end
  end

  describe ".foreign_key" do
    it "answers payload" do
      message = <<~CONTENT
        PG::ForeignKeyViolation: ERROR:  insert or update on table "playlist_item"
        violates foreign key constraint "playlist_item_playlist_id_fkey"
        DETAIL:  Key (playlist_id)=(29) is not present in table "playlist"
      CONTENT

      expect(problem_detail.foreign_key(message, "/api/test")).to eq(
        RFC::API::Problem[
          type: "/problem_details#invalid_foreign_key",
          status: :unprocessable_content,
          detail: "Invalid `playlist_id` value: 29. Does not exist.",
          instance: "/api/test"
        ]
      )
    end
  end

  describe ".out_of_range" do
    it "answers payload" do
      message = "PG::NumericValueOutOfRange: ERROR:  integer out of range"

      expect(problem_detail.out_of_range(message, "/api/test")).to eq(
        RFC::API::Problem[
          type: "/problem_details#invalid_numeric",
          status: :unprocessable_content,
          detail: "Integer out of range. Use a smaller value.",
          instance: "/api/test"
        ]
      )
    end
  end
end
