# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadScoringComponent::Helpers::EvidenceHelper do
  it "rejects an agent question used as evidence of a lead's license" do
    input = payload
    data = evidence
    data["import_readiness"] = { "value" => "licensed", "citations" => [{ "message_index" => 1, "quote" => input["conversation"][1]["text"] }] }
    expect { described_class.validate!(data, input["conversation"]) }.to raise_error(ScoringError)
  end

  it "rejects an invented quotation" do
    data = evidence
    data["import_readiness"]["citations"] = [{ "message_index" => 0, "quote" => "I have an import license" }]
    expect { described_class.validate!(data, payload["conversation"]) }.to raise_error(ScoringError)
  end

  it "rejects a negative message index" do
    data = evidence
    data["import_readiness"]["citations"] = [{ "message_index" => -1, "quote" => "2-3 FCL/month sustained." }]
    expect { described_class.validate!(data, payload["conversation"]) }.to raise_error(ScoringError)
  end
end
