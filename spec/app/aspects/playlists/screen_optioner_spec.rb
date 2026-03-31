# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Playlists::ScreenOptioner, :db do
  subject(:optioner) { described_class.new }

  describe "#call" do
    let(:model) { Factory[:model, label: "Model I"] }
    let(:screen) { Factory[:screen, model_id: model.id, label: "Screen I"] }

    it "answers option list" do
      model
      screen

      expect(optioner.call).to eq([["Select...", nil], ["Screen I - Model I", screen.id]])
    end

    it "uses custom prompt" do
      model
      screen

      expect(optioner.call(prompt: "Test")).to eq(
        [
          ["Test", nil],
          ["Screen I - Model I", screen.id]
        ]
      )
    end

    it "answers only prompt no screens exist" do
      expect(optioner.call).to eq([["Select...", nil]])
    end
  end
end
