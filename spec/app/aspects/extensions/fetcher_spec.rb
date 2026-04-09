# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Fetcher, :db do
  subject(:fetcher) { described_class.new http: }

  describe "#call" do
    let :exchange do
      Factory[
        :extension_exchange,
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
        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: [
                {
                  "title" => "Castle in the Sky",
                  "director" => "Hayao Miyazaki"
                }
              ]
            )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "image/png"})
        expect(fetcher.call(exchange)).to match(Success(having_attributes(data: "<binary>")))
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "text/csv"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: [
                {
                  "title" => "Castle in the Sky",
                  "director" => "Hayao Miyazaki"
                }
              ]
            )
          )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "text/plain"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: %w[one two three]
            )
          )
        )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "text/xml"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: {"catalog" => "Empty"}
            )
          )
        )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "application/xml"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: {"catalog" => "Empty"}
            )
          )
        )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "application/rss+xml"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: {"catalog" => "Empty"}
            )
          )
        )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "application/atom+xml"})

        expect(fetcher.call(exchange)).to match(
          Success(
            having_attributes(
              data: {"catalog" => "Empty"}
            )
          )
        )
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
        allow(exchange).to receive(:headers).and_return({"Content-Type" => "text/html"})

        expect(fetcher.call(exchange)).to match(
          Failure(
            having_attributes(
              error_code: nil,
              error_type: nil,
              error_body: "Unknown MIME Type: text/html."
            )
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
        expect(fetcher.call(exchange)).to match(
          Failure(
            having_attributes(
              error_code: 404,
              error_type: "application/json",
              error_body: {"error" => "Danger!"}.to_json(space: " ")
            )
          )
        )
      end
    end
  end
end
