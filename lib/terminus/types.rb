# frozen_string_literal: true

require "dry/types"
require "stringio"
require "tempfile"

module Terminus
  # The custom types.
  module Types
    include Dry.Types(default: :strict)

    File = Instance(IO) | Instance(Tempfile) | Instance(StringIO)

    Pathname = Constructor ::Pathname

    MACAddress = String.constrained(
      format: /\A[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}\Z/
    )

    Version = String.constrained(format: /\A\d+\.\d+\.\d+\Z/)
  end
end
