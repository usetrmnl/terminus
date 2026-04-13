# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Curler do
  subject(:curler) { described_class.new }

  describe "#initialize" do
    let :exchange do
      Factory.structs[
        :extension_exchange,
        verb: "get",
        template: "https://test.io/{{id}}",
        headers: {"accept" => "application/json"},
        body: {"sort" => "desc"}
      ]
    end

    it "answers GET request with headers and body" do
      text = curler.call(exchange, {"id" => "123"})

      expect(text).to eq(<<~CONTENT.strip)
        curl https://test.io/123 \\
             --header 'accept: application/json' \\
             --data $'{
          "sort": "desc"
        }'
      CONTENT
    end

    it "answers GET request with multiple headers" do
      exchange.headers.merge! "Authorization" => "Bearer secret",
                              "Content-Type" => "application/json"
      text = curler.call(exchange, {"id" => "123"})

      expect(text).to eq(<<~CONTENT.strip)
        curl https://test.io/123 \\
             --header 'accept: application/json' \\
             --header 'authorization: Bearer secret' \\
             --header 'content-type: application/json' \\
             --data $'{
          "sort": "desc"
        }'
      CONTENT
    end

    it "answers GET request with multi-line body" do
      exchange.body.merge! "query" => "test", "limit" => 10
      text = curler.call(exchange, {"id" => "123"})

      expect(text).to eq(<<~CONTENT.strip)
        curl https://test.io/123 \\
             --header 'accept: application/json' \\
             --data $'{
          "sort": "desc",
          "query": "test",
          "limit": 10
        }'
      CONTENT
    end

    it "answers GET request with no headers or body" do
      exchange = Factory.structs[:extension_exchange, verb: "get", template: "https://test.io"]
      expect(curler.call(exchange)).to eq("curl https://test.io")
    end

    it "answers POST request with headers and body" do
      exchange = Factory.structs[
        :extension_exchange,
        verb: "post",
        template: "https://test.io",
        headers: {"accept" => "application/json"},
        body: {"sort" => "desc"}
      ]

      text = curler.call exchange

      expect(text).to eq(<<~CONTENT.strip)
        curl --request POST https://test.io \\
             --header 'accept: application/json' \\
             --data $'{
          "sort": "desc"
        }'
      CONTENT
    end
  end
end
