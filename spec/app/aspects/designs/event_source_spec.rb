# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Designs::EventSource, :db do
  subject(:event_stream) { described_class.new screen.id, kernel: }

  include_context "with application dependencies"

  let(:screen) { Factory[:screen, :with_image] }
  let(:kernel) { class_spy Kernel }

  before { allow(kernel).to receive(:loop).and_yield }

  describe "#call" do
    let(:stream) { instance_spy StringIO }

    it "answers image when screen is found" do
      event_stream.call stream

      expect(stream).to have_received(:write).with(<<~CONTENT)
        event: preview
        data: <img class="image" src="memory://abc123.png" alt="Preview" width="1" height="1">

      CONTENT
    end

    it "sleeps for one second" do
      event_stream.call stream
      expect(kernel).to have_received(:sleep).with(0.5)
    end

    it "closes stream" do
      event_stream.call stream
      expect(stream).to have_received(:close)
    end

    it "answers loader image when screen doesn't exist" do
      event_stream = described_class.new(666, kernel:)

      event_stream.call stream

      expect(stream).to have_received(:write).with(<<~CONTENT)
        event: preview
        data: <img src="#{Hanami.app[:assets]["loader.svg"]}" alt="Loader" class="image" width="800" height="480">

      CONTENT
    end

    it "logs debug message when stream is disconnected" do
      allow(kernel).to receive(:loop).and_raise(Errno::EPIPE)
      event_stream.call stream

      expect(logger.reread).to match(%r(DEBUG.+stream disconnected\.))
    end
  end
end
