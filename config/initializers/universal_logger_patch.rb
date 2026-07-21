# auto_register: false
# frozen_string_literal: true

# Patches Hanami's universal logger to work with Cogger.
module UniversalLoggerPatch
  UNKNOWN_RACK = {verb: :get, status: 418, elapsed: "::", ip: 0, path: "/", length: 0}.freeze
  UNKNOWN_SQL = {db: :unknown, elapsed: 0, elapsed_unit: "ms", query: "N/A"}.freeze

  def _log_structured method, message, payload
    tags = _current_tags
    block_content = yield if block_given?
    formatter = case tags
                  in [:rack] then tags.delete :rack
                  in [:sql] if block_content.is_a? Hash then tags.delete :sql
                  else Hanami.env == :development ? :emoji : :json
                end
    attributes = {}

    if block_content.is_a? Hash
      attributes = build_log_attributes formatter, block_content
    else
      message = block_content
    end

    logger.formatter = formatter
    logger.public_send method, message, tags:, **attributes.merge(payload) if message
  end

  private

  def build_log_attributes formatter, content
    case formatter
      when :rack then UNKNOWN_RACK.merge content
      when :sql then UNKNOWN_SQL.merge content
      else {}
    end
  end
end

Hanami::UniversalLogger.prepend UniversalLoggerPatch
