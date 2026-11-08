# frozen_string_literal: true

module LeadScoringComponent
  module Helpers
    class EvidenceHelper
      VALUES = {
        "import_readiness" => %w[licensed experienced pending none unknown],
        "product_fit" => %w[match mismatch unknown],
        "volume" => %w[container_monthly below_container personal unknown],
        "business" => %w[established new unknown],
        "intent" => %w[wholesale personal unknown]
      }.freeze

      def self.schema
        {
          type: "object", additionalProperties: false, required: VALUES.keys,
          properties: VALUES.transform_values do |values|
            {
              type: "object", additionalProperties: false, required: %w[value citations],
              properties: {
                value: { type: "string", enum: values },
                citations: {
                  type: "array", items: {
                    type: "object", additionalProperties: false, required: %w[message_index quote],
                    properties: { message_index: { type: "integer" }, quote: { type: "string" } }
                  }
                }
              }
            }
          end
        }
      end

      def self.validate!(data, conversation)
        invalid! unless data.is_a?(Hash) && data.keys.sort == VALUES.keys.sort
        VALUES.each do |key, values|
          item = data[key]
          invalid! unless item.is_a?(Hash) && item.keys.sort == %w[citations value]
          invalid! unless values.include?(item["value"]) && item["citations"].is_a?(Array)
          citations = item["citations"]
          invalid! if citations.length > 5
          invalid! if item["value"] != "unknown" && citations.empty?
          citations.each do |citation|
            invalid! unless citation.is_a?(Hash) && citation.keys.sort == %w[message_index quote]
            index, quote = citation.values_at("message_index", "quote")
            invalid! unless index.is_a?(Integer) && index >= 0 && index < conversation.length
            message = conversation[index]
            invalid! unless message["role"] == "lead" && quote.is_a?(String) && !quote.strip.empty?
            invalid! unless message["text"].include?(quote)
          end
        end
        data.transform_values { |item| item["value"] }
      end

      def self.invalid!
        raise ScoringError.new("invalid_model_output", "Model evidence could not be validated; retry the request.", 502)
      end
    end
  end
end
