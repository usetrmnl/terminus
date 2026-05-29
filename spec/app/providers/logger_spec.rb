# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Providers::Logger do
  subject(:provider) { described_class.new provider_container:, target_container:, slice: }

  let(:provider_container) { Dry::Core::Container.new }
  let(:target_container) { Dry::Core::Container.new }
  let(:slice) { Hanami.app }

  describe "#prepare" do
    it "answers false due to already being loaded" do
      expect(provider.prepare).to be(false)
    end
  end

  describe "#start" do
    let(:cogger) { class_spy Cogger }
    let(:hub) { instance_spy Cogger::Hub }

    before { allow(cogger).to receive(:new).and_return hub }

    it "adds filters" do
      provider = described_class.new(
        environment: :test,
        resolver: proc { cogger },
        provider_container:,
        target_container:,
        slice:
      )

      provider.start
      expect(cogger).to have_received(:add_filters) do |*filters|
        expect(filters).to include(:access_token, :authorization)
      end
    end

    context "with test environment" do
      subject :provider do
        described_class.new environment: :test,
                            resolver: proc { cogger },
                            provider_container:,
                            target_container:,
                            slice:
      end

      it "initializes" do
        provider.start

        expect(cogger).to have_received(:new).with(
          id: :terminus,
          io: kind_of(StringIO),
          formatter: :json,
          level: :debug
        )
      end

      it "adds stream" do
        provider.start
        expect(hub).to have_received(:add_stream).with(io: "log/test.log")
      end
    end

    context "with development environment" do
      subject :provider do
        described_class.new environment: :development,
                            resolver: proc { cogger },
                            provider_container:,
                            target_container:,
                            slice:
      end

      it "initializes" do
        provider.start
        expect(cogger).to have_received(:new).with(id: :terminus)
      end

      it "adds stream" do
        provider.start
        expect(hub).to have_received(:add_stream).with(io: "log/development.log", formatter: :json)
      end
    end

    context "with any other environment" do
      subject :provider do
        described_class.new environment: :production,
                            resolver: proc { cogger },
                            provider_container:,
                            target_container:,
                            slice:
      end

      it "initializes" do
        provider.start
        expect(cogger).to have_received(:new).with(id: :terminus, formatter: :json)
      end
    end

    it "registers logger" do
      provider.start
      expect(provider_container.key?(:logger)).to be(true)
    end
  end
end
