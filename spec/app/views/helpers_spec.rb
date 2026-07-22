# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Helpers do
  subject(:helper) { described_class }

  include_context "with application dependencies"

  describe ".boolean" do
    it "answers green span when true" do
      expect(helper.boolean(true)).to eq(%(<span class="bit-text-green">true</span>))
    end

    it "answers red span when true" do
      expect(helper.boolean(false)).to eq(%(<span class="bit-text-red">false</span>))
    end
  end

  describe ".field_for" do
    let(:record) { Data.define(:label).new label: "Test" }
    let(:attributes) { {label: "Other"} }

    it "answers nil for missing attributes key and no record" do
      expect(helper.field_for(:unknown, attributes)).to be(nil)
    end

    it "answers attribute value when found" do
      expect(helper.field_for(:label, attributes, record)).to eq("Other")
    end

    it "answers record value when attribute is missing" do
      attributes.clear
      expect(helper.field_for(:label, attributes, record)).to eq("Test")
    end

    it "answers formatted Sequel time string when an instance of SQL Time" do
      record = Data.define(:start_at).new start_at: Sequel::SQLTime.new(2025, 1, 1, 10, 5, 1)
      expect(helper.field_for(:start_at, attributes, record)).to eq("10:05:01")
    end

    it "answers formatted time string when an instance of Time" do
      record = Data.define(:published_at).new published_at: Time.local(2025, 1, 2, 3, 4)
      expect(helper.field_for(:published_at, attributes, record)).to eq("2025-01-02T03:04")
    end
  end

  describe "#field_included?" do
    let(:record) { Data.define(:days).new days: %w[monday wednesday friday] }
    let(:attributes) { {days: ["wednesday"]} }

    it "answers true when included for record" do
      expect(helper.field_included?(:days, "monday", attributes, record)).to be(true)
    end

    it "answers true when record is missing but value is in attributes" do
      expect(helper.field_included?(:days, "wednesday", attributes)).to be(true)
    end

    it "answers false when record and attributes don't have value" do
      expect(helper.field_included?(:days, "sunday", attributes, record)).to be(false)
    end
  end

  describe "#git_sha_link" do
    let(:kernel) { class_double Kernel }

    it "answers version link when latest and tag SHAs match" do
      latest_sha = Hanami.app[:settings].git_latest_sha

      allow(kernel).to receive(:`).with("git rev-parse --quiet --short 1.2.3^{}")
                                  .and_return(latest_sha)

      expect(helper.git_link(kernel:)).to eq(
        %(<a class="link" href="https://alchemists.io/projects/terminus/versions/1.2.3/">) \
        "Version 1.2.3</a>"
      )
    end

    it "answers latest link when latest and tag SHAs don't match" do
      allow(kernel).to receive(:`).with("git rev-parse --quiet --short 1.2.3^{}")
                                  .and_return("different")

      expect(helper.git_link(kernel:)).to eq(
        %(<a class="link" href="https://github.com/usetrmnl/terminus/commit/abcdefghijkl">) \
        "Latest (ahead of 1.2.3)</a>"
      )
    end
  end

  describe "#git_latest_link" do
    it "answers version link when latest and tag SHAs match" do
      expect(helper.git_latest_link).to eq(
        %(<a class="link" href="https://github.com/usetrmnl/terminus/commit/abcdefghijkl">) \
        "Latest (ahead of 1.2.3)</a>"
      )
    end
  end

  describe "#git_version_link" do
    it "answers version link when latest and tag SHAs match" do
      expect(helper.git_version_link).to eq(
        %(<a class="link" href="https://alchemists.io/projects/terminus/versions/1.2.3/">) \
        "Version 1.2.3</a>"
      )
    end
  end

  describe ".human_at" do
    it "answers human date/time" do
      expect(helper.human_at(Time.utc(2025, 1, 2, 3, 4, 5))).to eq("January 02 2025 at 03:04 AM")
    end

    it "answers nil if not set" do
      expect(helper.human_at(nil)).to be(nil)
    end
  end

  describe ".human_time" do
    it "answers human date/time" do
      expect(helper.human_time(Time.utc(2025, 1, 2, 3, 4, 5))).to eq("03:04 AM")
    end

    it "answers nil if not set" do
      expect(helper.human_time(nil)).to be(nil)
    end
  end

  describe "#pluralize" do
    it "answers one" do
      expect(helper.pluralize("test", "s", 1)).to eq("1 test")
    end

    it "answers many" do
      expect(helper.pluralize("test", "s", 2)).to eq("2 tests")
    end
  end

  describe "#select_options" do
    it "answers options" do
      list = {one: "One", two: "Two"}

      expect(helper.select_options(list)).to eq(
        [
          ["Select...", ""],
          ["One", :one],
          ["Two", :two]
        ]
      )
    end

    it "answers prompt when given an empty array" do
      expect(helper.select_options([])).to contain_exactly(["Select...", ""])
    end
  end

  describe "#select_options_for" do
    it "answers record options" do
      record = Data.define(:id, :label).new 1, "Test"
      expect(helper.select_options_for([record])).to eq([["Select...", ""], ["Test", 1]])
    end

    it "answers record options with custom label" do
      record = Data.define(:id, :title).new 1, "Test"

      expect(helper.select_options_for([record], label: :title)).to eq(
        [
          ["Select...", ""],
          ["Test", 1]
        ]
      )
    end

    it "answers record options with custom ID" do
      record = Data.define(:name, :label).new "test", "Test"

      expect(helper.select_options_for([record], id: :name)).to eq(
        [
          ["Select...", ""],
          ["Test", "test"]
        ]
      )
    end

    it "answers prompt when given an empty array" do
      expect(helper.select_options_for([])).to contain_exactly(["Select...", ""])
    end
  end

  describe "#size" do
    it "answers zero if nil" do
      expect(helper.size(nil)).to eq("0.0 B")
    end

    it "answers zero if zero" do
      expect(helper.size(0)).to eq("0.0 B")
    end

    it "answers bytes" do
      expect(helper.size(50)).to eq("50.0 B")
    end

    it "answers kilobytes with single decimal precision" do
      expect(helper.size(1_130)).to eq("1.1 KB")
    end

    it "answers kilobytes with two decimal precision" do
      expect(helper.size(2_444)).to eq("2.39 KB")
    end

    it "answers megabytes" do
      expect(helper.size(1_572_864)).to eq("1.5 MB")
    end

    it "answers gigabytes" do
      expect(helper.size(1_073_741_824)).to eq("1.0 GB")
    end

    it "answers terabytes" do
      expect(helper.size(1_099_511_627_776)).to eq("1.0 TB")
    end
  end
end
