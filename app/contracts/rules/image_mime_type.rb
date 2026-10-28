# auto_register: false
# frozen_string_literal: true

module Terminus
  module Contracts
    module Rules
      ImageMimeType = lambda do
        next if values.dig(path.root, :mime_type).start_with? "image/"

        key.failure "must be an image"
      end
    end
  end
end
