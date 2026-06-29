# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Aspects::Extensions::Importers::Remote::Transforms::Resolver do
  subject(:resolver) { described_class.new }

  describe "#call" do
    it "answers variables" do
      expect(resolver.call(:variables)).to match(
        array_including(
          kind_of(Terminus::Aspects::Extensions::Importers::Remote::Transforms::Variables::Index),
          kind_of(Terminus::Aspects::Extensions::Importers::Remote::Transforms::Variables::Key)
        )
      )
    end
  end
end
