# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Browser do
  subject(:browser) { described_class.new }

  include_context "with application dependencies"

  describe "#initialize" do
    it "logs options" do
      described_class.new

      expect(logger.reread).to match(
        /DEBUG.+Ferrum browser options.+timeout.+process_timeout.+js_errors.+browser_options.+/
      )
    end

    context "with processing timeout error" do
      before { allow(settings).to receive(:to_h).and_return(ferrum_process_timeout: 0.01) }

      it "logs fatal message" do
        described_class.new
        expect(logger.reread).to match(/FATAL.+Browser process timed out after 0.01 seconds+/)
      end
    end
  end

  describe "#call" do
    let(:client) { class_double Ferrum::Browser, new: instance }
    let(:instance) { instance_spy Ferrum::Browser }

    it "doesn't restart when maximum pages haven't been reached" do
      browser.call
      expect(instance).not_to have_received(:restart)
    end

    it "answers success" do
      expect(browser.call).to be_success
    end

    context "with maximum renders reached" do
      subject(:browser) { described_class.new client:, maximum_renders: 1 }

      it "resets render count" do
        browser.call
        expect(browser.inspect).to include("@renders=0")
      end

      it "restarts browser" do
        browser.call
        expect(instance).to have_received(:restart)
      end

      it "logs debug message" do
        browser.call
        expect(logger.reread).to match(/DEBUG.+Browser restarted after maximum renders reached: 1/)
      end
    end

    context "with browser error" do
      subject(:browser) { described_class.new client: }

      let :message do
        "Unable to capture screenshot due to an issue with " \
        "page navigation, element interaction, or something else."
      end

      before { allow(instance).to receive(:create_page).and_raise(Ferrum::BrowserError, "Danger!") }

      it "logs debug message" do
        browser.call
        expect(logger.reread).to match(/DEBUG.+#{message}.+/)
      end

      it "answers failure" do
        expect(browser.call).to be_failure(message)
      end
    end

    context "with dead browser error" do
      subject(:browser) { described_class.new client: }

      let :message do
        "Browser is dead. This could mean the browser crashed, the server ran out of memory, " \
        "or a resource limit has been hit. Error: Danger!"
      end

      before do
        allow(instance).to receive(:create_page).and_raise(Ferrum::DeadBrowserError, "Danger!")
      end

      it "logs debug message" do
        browser.call
        expect(logger.reread).to match(/DEBUG.+#{message}/)
      end

      it "answers failure" do
        expect(browser.call).to be_failure(message)
      end
    end

    context "with timeout error" do
      subject(:browser) { described_class.new client: }

      let :message do
        "Browser timed out after 30 seconds. " \
        "This might be due to the page taking a long time to load."
      end

      it "logs debug message" do
        allow(instance).to receive(:create_page).and_raise(Ferrum::TimeoutError, "Danger!")
        browser.call

        expect(logger.reread).to match(/DEBUG.+#{message}.+/)
      end

      it "answers failure" do
        allow(instance).to receive(:create_page).and_raise(Ferrum::TimeoutError)
        expect(browser.call).to be_failure(message)
      end
    end

    context "with no such target error" do
      subject(:browser) { described_class.new client: }

      let(:message) { "Browser has no target due to page being closed or crashed. Error: Danger!" }

      before do
        allow(instance).to receive(:create_page).and_raise(Ferrum::NoSuchTargetError, "Danger!")
      end

      it "logs debug message" do
        browser.call
        expect(logger.reread).to match(/DEBUG.+#{message}/)
      end

      it "answers failure" do
        expect(browser.call).to be_failure(message)
      end
    end
  end
end
