# frozen_string_literal: true

module LeadScoringHelpers
  def payload(name = "hot")
    JSON.parse(File.read(File.expand_path("../fixtures/lead_scoring/#{name}.json", __dir__)))
  end

  def evidence(name = "hot")
    JSON.parse(File.read(File.expand_path("../fixtures/lead_scoring/#{name}_evidence.json", __dir__)))
  end

  def provider_url
    LeadScoringComponent::Services::EvidenceExtractorService::URL.to_s
  end

  def provider_response(data = evidence)
    { choices: [{ finish_reason: "stop", message: { content: JSON.generate(data) } }] }.to_json
  end

  def stub_provider(data = evidence)
    stub_request(:post, provider_url).to_return(status: 200, body: provider_response(data))
  end
end
