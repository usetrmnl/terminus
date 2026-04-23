# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Upgrader, :db do
  subject(:upgrader) { described_class.new }

  include_context "with application dependencies"

  let :extension do
    Factory[
      :extension,
      headers: {accept: "application/json"},
      verb: "post",
      uris: %w[https://test.io/1 https://test.io/2],
      body: {sort: :desc}
    ]
  end

  let(:repository) { Terminus::Repositories::ExtensionExchange.new }

  describe "#call" do
    it "adds extension exchanges" do
      extension
      upgrader.call

      expect(repository.all.map(&:to_h)).to match(
        [
          hash_including(
            headers: {"accept" => "application/json"},
            verb: "post",
            template: "https://test.io/1\nhttps://test.io/2",
            body: {"sort" => "desc"}
          )
        ]
      )
    end

    it "logs info" do
      extension
      upgrader.call
      expect(logger.reread).to match(/INFO.+Upgraded extension: #{extension.id}/)
    end
  end

  context "with non-poll extensions" do
    before do
      Factory[:extension, kind: "static"]
      upgrader.call
    end

    it "doesn't add extension exchanges" do
      expect(repository.all).to eq([])
    end
  end
end
