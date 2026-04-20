# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Jobs::Synchronizers::Model do
  subject(:job) { described_class.new palette:, model: }

  let(:palette) { instance_spy Terminus::Aspects::Palettes::Synchronizer }
  let(:model) { instance_spy Terminus::Aspects::Models::Synchronizer }

  include_context "with application dependencies"

  describe "#perform" do
    context "when enabled and palette synchronization is a success" do
      before { allow(palette).to receive(:call).and_return(Success()) }

      it "calls palette synchronizer" do
        job.perform
        expect(palette).to have_received(:call)
      end

      it "calls model synchronizer" do
        job.perform
        expect(model).to have_received(:call)
      end
    end

    context "when enabled and palette synchronization fails" do
      before { allow(palette).to receive(:call).and_return(Failure("Danger!")) }

      it "calls palette synchronizer" do
        job.perform
        expect(palette).to have_received(:call)
      end

      it "doesn't call model synchronizer" do
        job.perform
        expect(model).not_to have_received(:call)
      end

      it "answers failure" do
        expect(job.perform).to be_failure("Danger!")
      end
    end

    context "when disabled" do
      before { allow(settings).to receive(:model_synchronizer).and_return false }

      it "doesn't call model synchronizer" do
        job.perform
        expect(model).not_to have_received(:call)
      end

      it "logs information" do
        job.perform
        expect(logger.reread).to match(/INFO.+Model synchronization is disabled\./)
      end
    end
  end
end
