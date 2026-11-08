# frozen_string_literal: true

module LeadScoringComponent
  module Helpers
    class TranscriptHelper
      MAX_BYTES = 32_768

      def self.parse(raw)
        raise ScoringError.new("payload_too_large", "Request exceeds 32 KiB.", 413) if raw.bytesize > MAX_BYTES

        data = JSON.parse(raw)
        valid = data.is_a?(Hash) && string?(data["lead_id"], 128) && string?(data["channel"], 32)
        messages = data["conversation"] if valid
        valid &&= messages.is_a?(Array) && messages.length.between?(1, 100)
        valid &&= messages.all? do |message|
          message.is_a?(Hash) && %w[lead agent].include?(message["role"]) && string?(message["text"], 4_000)
        end
        valid &&= messages.any? { |message| message["role"] == "lead" }
        unless valid
          raise ScoringError.new("invalid_input", "Provide lead_id, channel, and 1–100 lead/agent messages with nonempty text.", 422)
        end

        data.slice("lead_id", "channel", "conversation")
      rescue JSON::ParserError, EncodingError
        raise ScoringError.new("invalid_json", "Request body must be valid JSON.", 400)
      end

      def self.string?(value, limit)
        value.is_a?(String) && value.valid_encoding? && !value.strip.empty? && value.length <= limit
      end
    end
  end
end
