# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::DeviceLog do
  subject(:part) { described_class.new value: log, rendering: Terminus::View.new.rendering }

  let(:log) { Factory.structs[:device_log] }

  describe "#level_class" do
    it "answers hint when debug" do
      allow(log).to receive(:level).and_return "debug"
      expect(part.level_class).to eq("bit-pill-hint")
    end

    it "answers active when info" do
      allow(log).to receive(:level).and_return "info"
      expect(part.level_class).to eq("bit-pill-active")
    end

    it "answers active when warn" do
      allow(log).to receive(:level).and_return "warn"
      expect(part.level_class).to eq("bit-pill-caution")
    end

    it "answers alert when error" do
      allow(log).to receive(:level).and_return "error"
      expect(part.level_class).to eq("bit-pill-alert")
    end

    it "answers danger when fatal" do
      allow(log).to receive(:level).and_return "fatal"
      expect(part.level_class).to eq("bit-pill-danger")
    end

    it "answers dark when any" do
      allow(log).to receive(:level).and_return "any"
      expect(part.level_class).to eq("bit-pill-dark")
    end

    it "answers dark with invalid level" do
      allow(log).to receive(:level).and_return "bogus"
      expect(part.level_class).to eq("bit-pill-dark")
    end
  end

  describe "#source_link" do
    it "answers default URI" do
      expect(part.source_link).to eq(
        "<a href=\"https://github.com/usetrmnl/trmnl-firmware/blob/main/src/test.cpp#L13\">" \
        "src/test.cpp:13</a>"
      )
    end

    it "answers custom URI" do
      expect(part.source_link(root: "https://source.io")).to eq(
        "<a href=\"https://source.io/src/test.cpp#L13\">src/test.cpp:13</a>"
      )
    end
  end
end
