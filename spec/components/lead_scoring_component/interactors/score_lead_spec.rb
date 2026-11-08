# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadScoringComponent::Interactors::ScoreLead do
  it "orchestrates validation, extraction, and scoring" do
    stub_provider(evidence("ambiguous"))
    expect(described_class.call(raw_body: payload("ambiguous").to_json)).to include(
      lead_id: "S003", score: 73, tier: "Warm", routing: "nurture_pool"
    )
  end

  it "does not invoke the provider for an invalid transcript" do
    expect { described_class.call(raw_body: "{}") }.to raise_error(ScoringError)
    expect(WebMock).not_to have_requested(:post, provider_url)
  end
end
