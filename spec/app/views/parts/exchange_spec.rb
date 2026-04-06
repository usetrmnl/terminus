# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Views::Parts::Exchange do
  subject(:part) { described_class.new value: exchange, rendering: view.new.rendering }

  let(:exchange) { Factory.structs[:extension_exchange, template: "https://test.io"] }

  let :view do
    Class.new Hanami::View do
      config.paths = [Hanami.app.root.join("app/templates")]
      config.template = "n/a"
    end
  end

  describe "#curl" do
    it "answers curl command" do
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

  describe "#formatted_data" do
    it "answers hash" do
      allow(exchange).to receive(:data).and_return(one: 1, two: 2)

      expect(part.formatted_data).to eq(<<~JSON.strip)
        {
          "one": 1,
          "two": 2
        }
      JSON
    end
  end

  describe "#formatted_errors" do
    it "answers hash" do
      allow(exchange).to receive(:errors).and_return("https://test.io" => {message: "Danger!"})

      expect(part.formatted_errors).to eq(<<~JSON.strip)
        {
          "https://test.io": {
            "message": "Danger!"
          }
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

  describe "#requests" do
    it "answers string with trimmed end" do
      uri = "https://test.io/a/path/to/a/test/to/a/long/test/example"
      allow(exchange).to receive(:template).and_return(uri)

      expect(part.requests).to contain_exactly("https://test.io/a/path/to/a/test/to/a/long/test...")
    end
  end
end
