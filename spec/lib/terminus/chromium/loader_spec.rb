# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Chromium::Loader do
  subject(:loader) { described_class.new }

  describe "#call" do
    it "loads defaults" do
      expect(loader.call).to eq(
        Terminus::Chromium::Model[
          browser_options: {
            "disable-dev-shm-usage" => nil,
            "disable-gpu" => nil,
            "hide-scrollbar" => nil,
            "no-sandbox" => nil
          },
          maximums: {
            "renders" => 500,
            "recoveries" => 1
          }
        ]
      )
    end
  end
end
