# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Shoter do
  subject(:shoter) { described_class.new }

  include_context "with temporary directory"

  before { Hanami.app.start :mini_magick }

  describe "#call" do
    let :content do
      <<~CONTENT
        <html>
          <head>
            <style>
              color: black;
              background-color: black;
            </style>
          </head>

          <body>
            <h1>Test</h1>
          </body>
        </html>
      CONTENT
    end

    let(:path) { temp_dir.join "test.jpeg" }

    it "creates screenshot" do
      shoter.call content, path, width: 800, height: 480
      image = MiniMagick::Image.new path

      expect(image).to have_attributes(width: 800, height: 480, type: "JPEG", exif: {})
    end

    it "answers success with image path" do
      expect(shoter.call(content, path, width: 800, height: 480)).to be_success(path)
    end

    it "answers failure when browser has issues" do
      browser = instance_double Terminus::Aspects::Browser, call: Failure("Danger!")
      shoter = described_class.new(browser:)

      expect(shoter.call(content, path, width: 800, height: 480)).to be_failure("Danger!")
    end
  end
end
