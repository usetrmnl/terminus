# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Screens::Shoter do
  subject(:shoter) { described_class.new }

  include_context "with temporary directory"
  include_context "with application dependencies"

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
    let(:instance) { instance_spy Ferrum::Browser }
    let(:browser) { class_double Ferrum::Browser, new: instance }

    it "creates screenshot" do
      shoter.call content, path, width: 800, height: 480
      image = MiniMagick::Image.open path

      expect(image).to have_attributes(width: 800, height: 480, type: "JPEG", exif: {})
    end

    it "answers image path" do
      expect(shoter.call(content, path, width: 800, height: 480)).to be_success(path)
    end

    context "with browser error" do
      subject(:shoter) { described_class.new browser: }

      before { allow(instance).to receive(:create_page).and_raise(Ferrum::BrowserError, "Danger!") }

      it "quits browser instance" do
        shoter.call content, path
        expect(instance).to have_received(:quit)
      end

      it "logs debug message" do
        shoter.call content, path
        expect(logger.reread).to match(/DEBUG.+Screen shoter has browser error.+/)
      end

      it "answers failure" do
        expect(shoter.call(content, path)).to be_failure(
          "Unable to capture screenshot due to an instance error such as " \
          "page navigation, element interaction, or something else."
        )
      end
    end

    context "with dead browser error" do
      subject(:shoter) { described_class.new browser: }

      before do
        allow(instance).to receive(:create_page).and_raise(Ferrum::DeadBrowserError, "Danger!")
      end

      it "logs debug message" do
        shoter.call content, path
        expect(logger.reread).to match(/DEBUG.+Screen shoter has dead browser: Danger!/)
      end

      it "answers failure" do
        expect(shoter.call(content, path)).to be_failure(
          "Unable to capture screenshot due to a dead browser. " \
          "This could mean the browser crashed, server is out of memory, " \
          "or a resource limitation has been hit."
        )
      end
    end

    context "with timeout error" do
      subject(:shoter) { described_class.new browser: }

      it "doesn't quit browser when nil" do
        allow(browser).to receive(:new).and_raise(Ferrum::TimeoutError)
        shoter.call content, path

        expect(instance).not_to have_received(:quit)
      end

      it "quits browser instance" do
        allow(instance).to receive(:create_page).and_raise(Ferrum::TimeoutError)
        shoter.call content, path

        expect(instance).to have_received(:quit)
      end

      it "logs debug message" do
        allow(instance).to receive(:create_page).and_raise(Ferrum::TimeoutError)
        shoter.call content, path

        expect(logger.reread).to match(/DEBUG.+Screen shoter has timeout.+/)
      end

      it "answers failure" do
        allow(instance).to receive(:create_page).and_raise(Ferrum::TimeoutError)

        expect(shoter.call(content, path)).to be_failure(
          "Unable to capture screenshot due to timming out after 30 seconds. " \
          "This might have happened due to the page taking a long time to load."
        )
      end
    end

    context "with no such target error" do
      subject(:shoter) { described_class.new browser: }

      before do
        allow(instance).to receive(:create_page).and_raise(Ferrum::NoSuchTargetError, "Danger!")
      end

      it "quits browser instance" do
        shoter.call content, path
        expect(instance).to have_received(:quit)
      end

      it "logs debug message" do
        shoter.call content, path
        expect(logger.reread).to match(/DEBUG.+Screen shoter has no such target: Danger!/)
      end

      it "answers failure" do
        expect(shoter.call(content, path)).to be_failure(
          "Unable to capture screenshot because the page closed or crashed."
        )
      end
    end

    context "with processing timeout error" do
      before { allow(settings).to receive(:to_h).and_return(ferrum_process_timeout: 0.01) }

      it "logs debug message" do
        shoter.call content, path
        expect(logger.reread).to match(/DEBUG.+Screen shoter has process timeout.+/)
      end

      it "answers failure" do
        expect(shoter.call(content, path)).to be_failure(
          "Unable to capture screenshot because the browser could not produce a " \
          "websocket URL within 0.01 seconds."
        )
      end
    end
  end
end
