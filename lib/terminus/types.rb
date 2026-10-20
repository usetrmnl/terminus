# frozen_string_literal: true

require "dry/types"
require "stringio"
require "tempfile"

module Terminus
  # The custom types.
  module Types
    include Dry.Types(default: :strict)

    URIs = Types::Array.constructor(-> value { value.split "," }).of(
      Dry::Types["string"].constrained(format: URI::DEFAULT_PARSER.make_regexp("https"))
    )

    File = Instance(IO) | Instance(Tempfile) | Instance(StringIO)

    LogLevel = String.constrained(format: /\A(debug|info|warn|error|fatal|any)\Z/)

    Pathname = Constructor ::Pathname

    MACAddress = String.constrained(
      format: /\A[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}:[0-9A-F]{2}\Z/
    )

    Version = String.constrained(format: /\A\d+\.\d+\.\d+\Z/)
  end
end
