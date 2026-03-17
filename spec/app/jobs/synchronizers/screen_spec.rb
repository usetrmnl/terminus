# frozen_string_literal: true

require "hanami_helper"
require "trmnl/api"

RSpec.describe Terminus::Jobs::Synchronizers::Screen, :db do
  subject(:job) { described_class.new synchronizer:, trmnl_api: }

  let(:synchronizer) { instance_spy Terminus::Aspects::Screens::Synchronizer }
  let(:trmnl_api) { instance_spy TRMNL::API::Client, display: Success(display) }

  include_context "with application dependencies"

  describe "#perform" do
    let(:devices) { [Factory[:device, proxy: true]] }

    let :display do
      TRMNL::API::Models::Display[image_url: "https://test.io/test.bmp", filename: "test.bmp"]
    end

    it "calls synchornizer when enabled" do
      devices
      job.perform

      expect(synchronizer).to have_received(:call).with(display)
    end

    context "with no devices" do
      let(:devices) { [] }

      it "doesn't synchronize" do
        job.perform
        expect(synchronizer).not_to have_received(:call)
      end
    end

    context "with no proxied devices" do
      let(:devices) { [Factory[:device]] }

      it "doesn't synchronize" do
        job.perform
        expect(synchronizer).not_to have_received(:call)
      end
    end

    context "with remote image failure" do
      let(:trmnl_api) { instance_spy TRMNL::API::Client, display: Failure("Danger!") }

      it "doesn't synchronize" do
        job.perform
        expect(synchronizer).not_to have_received(:call)
      end
    end

    context "when disabled" do
      before { allow(settings).to receive(:screen_synchronizer).and_return false }

      it "doesn't call synchronizer when disabled" do
        job.perform
        expect(synchronizer).not_to have_received(:call)
      end

      it "logs information" do
        job.perform
        expect(logger.reread).to match(/INFO.+Screen polling disabled\./)
      end
    end
  end
end
