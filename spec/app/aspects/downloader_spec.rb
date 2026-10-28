# frozen_string_literal: true

require "hanami_helper"
require "http"

RSpec.describe Terminus::Aspects::Downloader do
  subject(:downloader) { described_class.new http:, allowed_domains: ["test.io"] }

  include_context "with application dependencies"

  let(:http) { class_double HTTP, get: response }
  let(:response) { HTTP::Response.new uri:, body: "Test.", status: 200, version: 1.0 }
  let(:uri) { "https://test.io/test.txt" }

  describe "#call" do
    it "answers HTTP response" do
      expect(downloader.call(uri)).to be_success(response)
    end

    it "logs info" do
      downloader.call uri
      expect(logger.reread).to match(/INFO.+Downloaded: #{uri}\./)
    end

    it "answers HTTP response when all domains are allowed" do
      downloader = described_class.new http:, allowed_domains: []
      expect(downloader.call(uri)).to be_success(response)
    end

    context "with blocked domain" do
      subject(:downloader) { described_class.new http: }

      it "answers failure when scheme isn't HTTPS" do
        expect(downloader.call("http://test.io")).to be_failure(
          "Invalid scheme (use HTTPS): http://test.io."
        )
      end

      it "answers failure when blocked" do
        expect(downloader.call(uri)).to be_failure("Blocked domain: https://test.io/test.txt.")
      end

      it "logs error" do
        downloader.call uri
        expect(logger.reread).to match(/ERROR.+Blocked domain/)
      end
    end

    context "with download failure" do
      let(:http) { class_double HTTP, get: response }

      let :response do
        HTTP::Response.new uri:, body: "Danger!", status: 404, version: 1.0
      end

      it "answers failure" do
        expect(downloader.call(uri)).to be_failure(response)
      end

      it "logs error" do
        downloader.call uri
        expect(logger.reread).to match(/ERROR.+Danger!/)
      end
    end

    context "with request error" do
      before { allow(http).to receive(:get).and_raise(HTTP::RequestError, "Danger!") }

      it "answers failure" do
        expect(downloader.call(uri)).to be_failure("Danger!")
      end

      it "logs error" do
        downloader.call uri
        expect(logger.reread).to match(/ERROR.+Danger!/)
      end
    end

    context "with SSL error" do
      before { allow(http).to receive(:get).and_raise(OpenSSL::SSL::SSLError, "Danger!") }

      it "answers failure" do
        expect(downloader.call(uri)).to be_failure("Danger!")
      end

      it "logs error" do
        downloader.call uri
        expect(logger.reread).to match(/ERROR.+Danger!/)
      end
    end

    it "logs error when download can't be performed" do
      allow(response).to receive(:then).and_return(Failure(:danger))
      downloader.call uri

      expect(logger.reread).to match(%r(ERROR.+Unable to download:.+https://test.io/test.txt))
    end
  end
end
