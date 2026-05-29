# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Renderer, :db do
  subject(:renderer) { described_class.new }

  using Refinements::Hash

  describe "#call" do
    let(:extension) { Factory.structs[:extension, label: "Test", data: {}] }
    let(:model) { Factory[:model] }

    let :context do
      {
        "extension" => {
          "label" => "Test",
          "css_classes" => "screen screen--#{model.name} screen--1bit screen--landscape",
          "fields" => [],
          "values" => {},
          "data" => {}
        },
        "screen_variables" => "",
        "sensors" => []
      }
    end

    context "with image kind" do
      subject(:renderer) { described_class.new image: }

      let(:image) { instance_spy Terminus::Aspects::Extensions::Renderers::Image }

      it "delegates to poll renderer" do
        allow(extension).to receive(:kind).and_return("image")
        renderer.call extension, model_id: model.id

        expect(image).to have_received(:call).with(extension, context:)
      end
    end

    context "with home assistant kind" do
      subject(:renderer) { described_class.new home_assistant: }

      let(:home_assistant) { instance_spy Terminus::Aspects::Extensions::Renderers::HomeAssistant }

      it "delegates to home assistant renderer" do
        allow(extension).to receive(:kind).and_return("home_assistant")
        renderer.call extension, model_id: model.id

        expect(home_assistant).to have_received(:call).with(extension, context:)
      end
    end

    context "with poll kind" do
      subject(:renderer) { described_class.new poll: }

      let(:poll) { instance_spy Terminus::Aspects::Extensions::Renderers::Poll }

      it "delegates to poll renderer" do
        renderer.call extension, model_id: model.id
        expect(poll).to have_received(:call).with(extension, context:)
      end
    end

    context "with static kind" do
      subject(:renderer) { described_class.new static: }

      let(:static) { instance_spy Terminus::Aspects::Extensions::Renderers::Static }

      it "delegates to static renderer" do
        allow(extension).to receive(:kind).and_return("static")
        renderer.call extension, model_id: model.id

        expect(static).to have_received(:call).with(extension, context:)
      end
    end

    context "with unknown kind" do
      it "answers failure" do
        allow(extension).to receive(:kind).and_return("bogus")

        expect(renderer.call(extension)).to be_failure("Unsupported extension kind: bogus.")
      end
    end
  end
end
