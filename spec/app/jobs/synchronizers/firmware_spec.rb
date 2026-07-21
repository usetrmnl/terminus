# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Synchronizers::Firmware do
  subject(:job) { described_class.new synchronizer: }

  let(:synchronizer) { instance_spy Terminus::Aspects::Firmware::Synchronizer }

  include_context "with application dependencies"

  describe "#perform" do
    it "calls synchornizer when enabled" do
      job.perform
      expect(synchronizer).to have_received(:call)
    end

    context "when disabled" do
      before { allow(settings).to receive(:firmware_synchronizer).and_return false }

      it "doesn't call synchronizer" do
        job.perform
        expect(synchronizer).not_to have_received(:call)
      end

      it "logs information" do
        job.perform
        expect(logger.reread).to match(/WARN.+Firmware synchronization is disabled\./)
      end
    end
  end
end
