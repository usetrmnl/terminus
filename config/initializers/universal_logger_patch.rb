# auto_register: false
# frozen_string_literal: true

# Patches Hanami's universal logger.
module UniversalLoggerPatch
  def _log_structured method, message, payload
    tags = Array _current_tags

    return logger.public_send(method, message, tags:, **payload) unless block_given?

    block_content = yield

    if block_content.is_a?(Hash) && block_content.key?(:db)
      tags.append block_content
    else
      message = block_content
    end

    logger.public_send method, message, tags:, **payload
  end
end

Hanami::UniversalLogger.prepend UniversalLoggerPatch
