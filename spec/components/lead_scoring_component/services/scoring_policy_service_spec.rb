# frozen_string_literal: true

require "rails_helper"

RSpec.describe LeadScoringComponent::Services::ScoringPolicyService do
  { "hot" => [93, "Hot", "kam_handoff"], "cold" => [25, "Cold", "auto_archive"], "ambiguous" => [73, "Warm", "nurture_pool"] }.each do |name, expected|
    it "routes the #{name} example using controlled evidence" do
      input = payload(name)
      facts = LeadScoringComponent::Helpers::EvidenceHelper.validate!(evidence(name), input.fetch("conversation"))
      result = described_class.call(input.fetch("lead_id"), facts)
      expect(result.values_at(:score, :tier, :routing)).to eq(expected)
      expect(result[:lead_id]).to eq(input["lead_id"])
      expect(result[:reasoning].scan(/\./).length).to eq(2)
    end
  end

  it "nurtures unknown leads without inventing facts" do
    facts = LeadScoringComponent::Helpers::EvidenceHelper::VALUES.transform_values { "unknown" }
    result = described_class.call("unknown", facts)
    expect(result.values_at(:score, :tier, :routing)).to eq([40, "Warm", "nurture_pool"])
    expect(result[:reasoning]).to include("unknown")
  end

  it "caps an otherwise strong lead with a pending license at Warm" do
    facts = { "import_readiness" => "pending", "product_fit" => "match", "volume" => "container_monthly", "business" => "established", "intent" => "wholesale" }
    expect(described_class.call("pending", facts)).to include(score: 74, tier: "Warm")
  end

  it "keeps scores and routing consistent across all 540 evidence combinations" do
    categories = LeadScoringComponent::Helpers::EvidenceHelper::VALUES
    categories.values.first.product(*categories.values.drop(1)).each do |values|
      result = described_class.call("matrix", categories.keys.zip(values).to_h)
      score = result.fetch(:score)
      expect(score).to be_a(Integer).and be_between(0, 100)
      expected = if score >= 75
                   ["Hot", "kam_handoff"]
                 elsif score >= 40
                   ["Warm", "nurture_pool"]
                 else
                   ["Cold", "auto_archive"]
                 end
      expect(result.values_at(:tier, :routing)).to eq(expected)
    end
  end
end
