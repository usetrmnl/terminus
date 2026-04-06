# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Exchange do
  subject(:part) { described_class.new value: exchange, rendering: view.new.rendering }

  let(:exchange) { Factory.structs[:extension_exchange] }

  let :view do
    Class.new Hanami::View do
      config.paths = [Hanami.app.root.join("app/templates")]
      config.template = "n/a"
    end
  end

  describe "#curl" do
    it "answers curl requests" do
      allow(exchange).to receive(:template).and_return "https://test.io"
      expect(part.curl).to eq("curl https://test.io")
    end
  end

  describe "#formatted_body" do
    it "answers hash" do
      allow(exchange).to receive(:body).and_return(sort: :name, limit: 5)

      expect(part.formatted_body).to eq(<<~JSON.strip)
        {
          "sort": "name",
          "limit": 5
        }
      JSON
    end
  end

  describe "#formatted_headers" do
    it "answers hash" do
      allow(exchange).to receive(:headers).and_return(
        "Accept" => "application/json",
        "Accept-Encoding" => "deflate,gzip"
      )

      expect(part.formatted_headers).to eq(<<~JSON.strip)
        {
          "Accept": "application/json",
          "Accept-Encoding": "deflate,gzip"
        }
      JSON
    end
  end

  describe "#formatted_verb" do
    it "answers as upcase" do
      expect(part.formatted_verb).to eq("GET")
    end
  end

  describe "#trimmed_request" do
    it "answers string with trimmed end" do
      allow(exchange).to receive(:template).and_return("https://test.io/a/b/c/a_test_example")
      expect(part.trimmed_request).to eq("GET https://test.io/a...")
    end
  end
end
