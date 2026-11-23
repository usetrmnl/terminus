# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Errors::Finesse do
  subject(:finesse) { described_class }

  let :errors do
    YAML.load_file SPEC_ROOT.join("support/fixtures/errors.yml"), symbolize_names: true
  end

  describe ".duplicate" do
    it "answers readable message" do
      message = errors.fetch :duplicate

      expect(finesse.duplicate(message)).to eq(
        %(Label must be unique. Please use a value other than "Demo".)
      )
    end
  end

  describe ".enum" do
    it "answers readable message" do
      message = errors.fetch :enum

      expect(finesse.enum(message)).to eq(
        %(Invalid value for mode: "other". Use: "automatic" or "manual".)
      )
    end
  end

  describe ".foreign_key" do
    it "answers readable message" do
      message = errors.fetch :foreign_key

      expect(finesse.foreign_key(message)).to eq(
        "Invalid `playlist_id` value: 29. Does not exist."
      )
    end
  end

  describe ".out_of_range" do
    it "answers readable message" do
      message = errors.fetch :out_of_range
      expect(finesse.out_of_range(message)).to eq("Integer out of range. Use a smaller value.")
    end
  end
end
