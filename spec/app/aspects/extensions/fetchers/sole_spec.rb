# frozen_string_literal: true

require "hanami_helper"
require "http"

RSpec.describe Terminus::Aspects::Extensions::Fetchers::Sole do
  subject(:fetcher) { described_class.new http: }

  let(:http) { class_double HTTP }

  before { allow(http).to receive_messages(headers: http, follow: http) }

  describe "#call" do
    let :input do
      Terminus::Aspects::Extensions::Fetchers::Input[
        headers: {"Accept" => "application/json"},
        uri: "https://ghibliapi.vercel.app/films"
      ]
    end

    context "with JSON" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/json"},
                                      body: [
                                        {
                                          title: "Castle in the Sky",
                                          director: "Hayao Miyazaki"
                                        }
                                      ].to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        expect(fetcher.call(input)).to be_success(
          data: [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ],
          error: {}
        )
      end
    end

    context "with JSON-LD" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/ld+json"},
                                      body: {
                                        "@context" => "https://json-ld.org/contexts/person.jsonld",
                                        "@id" => "http://dbpedia.org/resource/John_Lennon",
                                        name: "John Lennon",
                                        born: "1940-10-09",
                                        spouse: [
                                          "http://dbpedia.org/resource/Yoko_Ono",
                                          "http://dbpedia.org/resource/Cynthia_Lennon"
                                        ]
                                      }.to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "application/ld+json"})

        expect(result).to be_success(
          data: {
            "@context" => "https://json-ld.org/contexts/person.jsonld",
            "@id" => "http://dbpedia.org/resource/John_Lennon",
            "name" => "John Lennon",
            "born" => "1940-10-09",
            "spouse" => [
              "http://dbpedia.org/resource/Yoko_Ono",
              "http://dbpedia.org/resource/Cynthia_Lennon"
            ]
          },
          error: {}
        )
      end
    end

    context "with GeoJSON" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/geo+json"},
                                      body: {
                                        "@context" => [
                                          "https://geojson.org/geojson-ld/geojson-context.jsonld",
                                          {
                                            "@version": "1.1"
                                          }
                                        ],
                                        type: "Feature",
                                        geometry: {},
                                        properties: {}
                                      }.to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "application/geo+json"})

        expect(result).to be_success(
          data: {
            "@context" => [
              "https://geojson.org/geojson-ld/geojson-context.jsonld",
              {
                "@version" => "1.1"
              }
            ],
            "type" => "Feature",
            "geometry" => {},
            "properties" => {}
          },
          error: {}
        )
      end
    end

    context "with arbitrary JSON schema" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/fake!_#&-^$valid+json"},
                                      body: [
                                        {
                                          title: "Castle in the Sky",
                                          director: "Hayao Miyazaki"
                                        }
                                      ].to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(
          headers: {content_type: "application/fake!#&-^$but_valid+json"}
        )

        expect(result).to be_success(
          data: [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ],
          error: {}
        )
      end
    end

    context "with invalid JSON MIME type" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/+json"},
                                      body: [
                                        {
                                          title: "Castle in the Sky",
                                          director: "Hayao Miyazaki"
                                        }
                                      ].to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers failure" do
        result = fetcher.call input.with(headers: {content_type: "application/+json"})

        expect(result).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Unknown MIME Type: application/+json."
            }
          )
        )
      end
    end

    context "with image" do
      before do
        response = HTTP::Response.new headers: {content_type: "image/png"},
                                      body: {}.to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "image/png"})
        expect(result).to be_success(data: "{}", error: {})
      end
    end

    context "with CSV" do
      before do
        body = <<~CONTENT
          title,director
          Castle in the Sky,Hayao Miyazaki
        CONTENT

        response = HTTP::Response.new headers: {content_type: "text/csv"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "text/csv"})

        expect(result).to be_success(
          data: [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ],
          error: {}
        )
      end
    end

    context "with text" do
      before do
        body = <<~CONTENT
          one
          two
          three
        CONTENT

        response = HTTP::Response.new headers: {content_type: "text/plain"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "text/plain"})
        expect(result).to be_success(data: %w[one two three], error: {})
      end
    end

    context "with XML (text)" do
      before do
        body = <<~CONTENT
          <?xml version="1.0" encoding="UTF-8"?>
          <catalog>Empty</catalog>
        CONTENT

        response = HTTP::Response.new headers: {content_type: "text/xml"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "text/xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (application)" do
      before do
        body = <<~CONTENT
          <?xml version="1.0" encoding="UTF-8"?>
          <catalog>Empty</catalog>
        CONTENT

        response = HTTP::Response.new headers: {content_type: "application/xml"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "application/xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (RSS)" do
      before do
        body = <<~CONTENT
          <?xml version="1.0" encoding="UTF-8"?>
          <catalog>Empty</catalog>
        CONTENT

        response = HTTP::Response.new headers: {content_type: "application/rss+xml"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "application/rss+xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (Atom)" do
      before do
        body = <<~CONTENT
          <?xml version="1.0" encoding="UTF-8"?>
          <catalog>Empty</catalog>
        CONTENT

        response = HTTP::Response.new headers: {content_type: "application/atom+xml"},
                                      body:,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {content_type: "application/atom+xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with POST body" do
      let :input do
        Terminus::Aspects::Extensions::Fetchers::Input[
          headers: {content_type: "application/json"},
          verb: :post,
          uri: "https://test.io",
          body: {query: :test}
        ]
      end

      before do
        response = HTTP::Response.new headers: {content_type: "application/json"},
                                      body: {name: :test}.to_json,
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:post).and_return response
      end

      it "processes request" do
        fetcher.call input
        expect(http).to have_received(:post).with(input.uri, json: {query: :test})
      end

      it "answers success" do
        expect(fetcher.call(input)).to be_success(data: {"name" => "test"}, error: {})
      end
    end

    context "with POST but without body" do
      let :input do
        Terminus::Aspects::Extensions::Fetchers::Input[
          headers: {content_type: "application/json"},
          verb: :post,
          uri: "https://test.io"
        ]
      end

      before do
        response = HTTP::Response.new headers: {content_type: "application/json"},
                                      body: {},
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:post).and_return response
      end

      it "processes request" do
        fetcher.call input
        expect(http).to have_received(:post).with(input.uri)
      end

      it "answers success" do
        expect(fetcher.call(input)).to be_success(data: "{}", error: {})
      end
    end

    context "with unknown MIME type" do
      before do
        response = HTTP::Response.new headers: {content_type: "text/html"},
                                      body: "<p>A test.</p>",
                                      status: 200,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers failure" do
        result = fetcher.call input.with(headers: {content_type: "text/html"})
        expect(result).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Unknown MIME Type: text/html."
            }
          )
        )
      end
    end

    context "with bad HTTP status" do
      before do
        response = HTTP::Response.new headers: {content_type: "application/json"},
                                      body: {error: "Danger!"}.to_json,
                                      status: 404,
                                      version: 1.0

        allow(http).to receive(:get).and_return response
      end

      it "answers failure" do
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: 404,
              type: "application/json",
              body: {error: "Danger!"}.to_json
            }
          )
        )
      end
    end

    context "with HTTP request error" do
      let(:http) { class_double HTTP }

      it "answers failure" do
        allow(http).to receive(:headers).and_raise HTTP::RequestError, "Danger!"
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Unable to make request"
            }
          )
        )
      end
    end

    context "with HTTP connection error" do
      let(:http) { class_double HTTP }

      it "answers failure" do
        allow(http).to receive(:headers).and_raise HTTP::ConnectionError, "Danger!"
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Unable to connect"
            }
          )
        )
      end
    end

    context "with HTTP timeout error" do
      let(:http) { class_double HTTP }

      it "answers failure" do
        allow(http).to receive(:headers).and_raise HTTP::TimeoutError, "Danger!"
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Connection timed out"
            }
          )
        )
      end
    end

    context "with SSL error" do
      let(:http) { class_double HTTP }

      it "answers failure" do
        allow(http).to receive(:headers).and_raise OpenSSL::SSL::SSLError, "Danger!"
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: nil,
              type: nil,
              body: "Unable to secure connection"
            }
          )
        )
      end
    end
  end
end
