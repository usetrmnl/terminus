# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetchers::Sole do
  subject(:fetcher) { described_class.new http: }

  describe "#call" do
    let :input do
      Terminus::Aspects::Extensions::Fetchers::Input[
        headers: {"Accept" => "application/json"},
        uri: "https://ghibliapi.vercel.app/films"
      ]
    end

    context "with JSON" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/json"
            status 200

            <<~BODY
              [
                {
                  "title": "Castle in the Sky",
                  "director": "Hayao Miyazaki"
                }
              ]
            BODY
          end
        end
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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/ld+json"
            status 200

            <<~BODY
              {
                "@context": "https://json-ld.org/contexts/person.jsonld",
                "@id": "http://dbpedia.org/resource/John_Lennon",
                "name": "John Lennon",
                "born": "1940-10-09",
                "spouse": [
                  "http://dbpedia.org/resource/Yoko_Ono",
                  "http://dbpedia.org/resource/Cynthia_Lennon"
                ]
              }
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/ld+json"})

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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/geo+json"
            status 200

            <<~BODY
              {
                "@context": [
                  "https://geojson.org/geojson-ld/geojson-context.jsonld",
                  {
                    "@version": "1.1"
                  }
                ],
                "type": "Feature",
                "geometry": {},
                "properties": {}
              }
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/geo+json"})

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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/fake!#&-^$but_valid+json"
            status 200

            <<~BODY
              [
                {
                  "title": "Castle in the Sky",
                  "director": "Hayao Miyazaki"
                }
              ]
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(
          headers: {"Content-Type" => "application/fake!#&-^$but_valid+json"}
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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/+json"
            status 200

            <<~BODY
              [
                {
                  title: "Castle in the Sky",
                  director: "Hayao Miyazaki"
                }
              ]
            BODY
          end
        end
      end

      it "answers failure" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/+json"})

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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "image/png"
            status 200

            "<binary>"
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "image/png"})
        expect(result).to be_success(data: "<binary>", error: {})
      end
    end

    context "with CSV" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "text/csv"
            status 200

            <<~BODY
              title,director
              Castle in the Sky,Hayao Miyazaki
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "text/csv"})

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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "text/plain"
            status 200

            <<~BODY
              one
              two
              three
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "text/plain"})
        expect(result).to be_success(data: %w[one two three], error: {})
      end
    end

    context "with XML (text)" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "text/xml"
            status 200

            <<~BODY
              <?xml version="1.0" encoding="UTF-8"?>
              <catalog>Empty</catalog>
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "text/xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (application)" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/xml"
            status 200

            <<~BODY
              <?xml version="1.0" encoding="UTF-8"?>
              <catalog>Empty</catalog>
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (RSS)" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/rss+xml"
            status 200

            <<~BODY
              <?xml version="1.0" encoding="UTF-8"?>
              <catalog>Empty</catalog>
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/rss+xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with XML (Atom)" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/atom+xml"
            status 200

            <<~BODY
              <?xml version="1.0" encoding="UTF-8"?>
              <catalog>Empty</catalog>
            BODY
          end
        end
      end

      it "answers success" do
        result = fetcher.call input.with(headers: {"Content-Type" => "application/atom+xml"})
        expect(result).to be_success(data: {"catalog" => "Empty"}, error: {})
      end
    end

    context "with unknown MIME type" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "text/html"
            status 200

            <<~HTML
              <p>A test.</p>
            HTML
          end
        end
      end

      it "answers failure" do
        result = fetcher.call input.with(headers: {"Content-Type" => "text/html"})
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
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/json"
            status 404

            <<~BODY.strip
              {"error": "Danger!"}
            BODY
          end
        end
      end

      it "answers failure" do
        expect(fetcher.call(input)).to match(
          Failure(
            data: {},
            error: {
              uri: "https://ghibliapi.vercel.app/films",
              code: 404,
              type: "application/json",
              body: {"error" => "Danger!"}.to_json(space: " ")
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
