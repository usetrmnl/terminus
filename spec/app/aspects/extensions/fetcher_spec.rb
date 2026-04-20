# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetcher do
  subject(:fetcher) { described_class.new http: }

  describe "#call" do
    let(:uri) { "https://ghibliapi.vercel.app/films" }
    let(:extension) { Factory.structs[:extension, uris: [uri]] }

    context "with specific content type header" do
      let :extension do
        Factory.structs[:extension, headers: {"Accept" => "application/json"}, uris: [uri]]
      end

      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "text/plain"
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

      it "answers success due to header overriding response content type" do
        expect(fetcher.call(uri, extension)).to be_success(
          [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ]
        )
      end
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
        expect(fetcher.call(uri, extension)).to be_success(
          [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ]
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
        expect(fetcher.call(uri, extension)).to be_success(
          {
            "@context" => "https://json-ld.org/contexts/person.jsonld",
            "@id" => "http://dbpedia.org/resource/John_Lennon",
            "name" => "John Lennon",
            "born" => "1940-10-09",
            "spouse" => [
              "http://dbpedia.org/resource/Yoko_Ono",
              "http://dbpedia.org/resource/Cynthia_Lennon"
            ]
          }
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
        expect(fetcher.call(uri, extension)).to be_success(
          {
            "@context" => [
              "https://geojson.org/geojson-ld/geojson-context.jsonld",
              {
                "@version" => "1.1"
              }
            ],
            "type" => "Feature",
            "geometry" => {},
            "properties" => {}
          }
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
        expect(fetcher.call(uri, extension)).to be_success(
          [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ]
        )
      end
    end

    context "with invalid json MIME type" do
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
        expect(fetcher.call(uri, extension)).to be_failure("Unknown MIME Type: application/+json.")
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
        expect(fetcher.call(uri, extension)).to be_success("<binary>")
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
        expect(fetcher.call(uri, extension)).to be_success(
          [
            {
              "title" => "Castle in the Sky",
              "director" => "Hayao Miyazaki"
            }
          ]
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
        expect(fetcher.call(uri, extension)).to be_success(%w[one two three])
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
        expect(fetcher.call(uri, extension)).to be_success("catalog" => "Empty")
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
        expect(fetcher.call(uri, extension)).to be_success("catalog" => "Empty")
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
        expect(fetcher.call(uri, extension)).to be_success("catalog" => "Empty")
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
        expect(fetcher.call(uri, extension)).to be_success("catalog" => "Empty")
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
        expect(fetcher.call(uri, extension)).to be_failure("Unknown MIME Type: text/html.")
      end
    end

    context "with bad HTTP status" do
      let :http do
        HTTP::Fake::Client.new do
          get "/films" do
            headers["Content-Type"] = "application/json"
            status 404

            <<~BODY
              {"error": "Danger!"}
            BODY
          end
        end
      end

      it "answers failure" do
        expect(fetcher.call(uri, extension)).to match(Failure(kind_of(HTTP::Response)))
      end
    end
  end
end
