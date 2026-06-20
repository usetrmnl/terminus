# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Structs::ScreenTemplate do
  subject(:screen_template) { Factory.structs[:screen_template, label: "Test", name: "test"] }

  describe "#screen_attributes" do
    it "answers attributes" do
      expect(screen_template.screen_attributes).to eq(
        template_id: 1,
        label: "Test",
        name: "test",
        content: "<h1>Test</h1>"
      )
    end
  end
end
