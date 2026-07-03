# auto_register: false
# frozen_string_literal: true

# Patches Hanami's universal logger to work with Cogger.
module UniversalLoggerPatch
  def _log_structured method, message, payload
    tags = _current_tags
    block_content = yield if block_given?

    logger.formatter = case tags
                         in [:rack] then tags.delete :rack
                         in [:sql] if block_content.is_a? Hash then tags.delete :sql
                         else Hanami.env == :development ? :emoji : :json
                       end

    unless block_content.is_a? Hash
      message = block_content
      block_content = {}
    end

    logger.public_send method, message, tags:, **block_content.merge!(payload)
  end
end

Hanami::UniversalLogger.prepend UniversalLoggerPatch
