# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Designs::Middleware do
  subject(:middleware) { described_class.new application, pattern: %r(/preview/(?<id>.+)) }

  let(:application) { proc { [200, {}, []] } }

  describe "#call" do
    let(:environment) { Rack::MockRequest.env_for path, method: :get }
    let(:path) { +"/preview/1" }

    it "answers event stream when path matches" do
      expect(middleware.call(environment)).to match(
        array_including(
          200,
          {
            "Cache-Control" => "no-cache",
            "Content-Type" => "text/event-stream",
            "X-Accel-Buffering" => "no"
          },
          instance_of(Terminus::Aspects::Designs::EventSource)
        )
      )
    end

    it "passes ID to event stream" do
      event_stream = class_spy Terminus::Aspects::Designs::EventSource

      middleware = described_class.new(
        application,
        pattern: %r(/preview/(?<id>.+)),
        event_stream:
      )

      middleware.call environment

      expect(event_stream).to have_received(:new).with("1")
    end

    it "marks as I/O bound" do
      marker = instance_spy Proc
      environment["puma.mark_as_io_bound"] = marker
      middleware.call environment

      expect(marker).to have_received(:call)
    end

    it "doesn't mark as I/O bound when key is missing" do
      environment.delete "puma.mark_as_io_bound"
      expectation = proc { middleware.call environment }

      expect(&expectation).not_to raise_error
    end

    it "updates session options to be skipped" do
      environment["rack.session.options"] = {skip: false}
      middleware.call environment

      expect(environment.dig("rack.session.options", :skip)).to be(true)
    end

    it "answers original response when path doesn't match" do
      path.replace "/bogus"
      expect(middleware.call(environment)).to eq([200, {}, []])
    end

    it "answers original response when verb doesn't match" do
      path.replace "/test/1/example"
      expect(middleware.call(environment)).to eq([200, {}, []])
    end
  end
end
