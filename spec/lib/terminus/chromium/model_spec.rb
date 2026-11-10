# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Chromium::Model do
  subject :model do
    described_class[
      browser_options: {"no-sandbox" => nil},
      maximums: {"renders" => 500, "recoveries" => 1}
    ]
  end

  describe "#merge_options" do
    it "merges options" do
      options = {"test" => "example"}

      expect(model.merge_options(options)).to eq(
        "test" => "example",
        browser_options: {"no-sandbox" => nil}
      )
    end
  end

  describe "#maximum_renders" do
    it "answers maximum" do
      expect(model.maximum_renders).to eq(500)
    end
  end

  describe "#maximum_recoveries" do
    it "answers maximum" do
      expect(model.maximum_recoveries).to eq(1)
    end
  end
end
