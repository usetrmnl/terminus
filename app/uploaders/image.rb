# auto_register: false
# frozen_string_literal: true

module Terminus
  module Uploaders
    # Processes image uploads.
    class Image < Hanami.app[:shrine]
      add_metadata :bit_depth do |io|
        MiniMagick::Image.open(io.path).data["depth"] if io.respond_to? :path
      end

      add_metadata(:checksum) { |io| calculate_signature io, :md5 }

      Attacher.validate do
        validate_mime_type %w[image/bmp image/png]
        validate_extension %w[bmp png]
      end
    end
  end
end
