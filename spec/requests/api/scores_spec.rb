# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Lead scoring HTTP API" do
  let(:app) { Rack::MockRequest.new(Rails.application) }

  def post_score(body, content_type: "application/json")
    app.post("/api/score", "CONTENT_TYPE" => content_type, input: body)
  end

  %w[hot cold ambiguous].each do |name|
    it "returns the complete contract for the #{name} example" do
      stub_provider(evidence(name))
      response = post_score(payload(name).to_json)
      expect(response.status).to eq(200)
      expect(response.content_type).to include("application/json")
      body = JSON.parse(response.body)
      expect(body.keys.sort).to eq(%w[lead_id reasoning routing score tier])
      expect(body["lead_id"]).to eq(payload(name)["lead_id"])
    end
  end

  it "returns JSON 400 for malformed JSON without calling the provider" do
    response = post_score("{")
    expect(response.status).to eq(400)
    expect(JSON.parse(response.body).dig("error", "code")).to eq("invalid_json")
    expect(WebMock).not_to have_requested(:post, provider_url)
  end

  it "rejects invalid fields and messages before provider access" do
    cases = [nil, [], {}, payload.merge("conversation" => []), payload.merge("lead_id" => 123),
             payload.merge("conversation" => [{ "role" => "system", "text" => "hello" }]),
             payload.merge("conversation" => [{ "role" => "agent", "text" => "hello" }]),
             payload.merge("conversation" => [{ "role" => "lead", "text" => " " }])]
    cases.each { |input| expect(post_score(input.to_json).status).to eq(422) }
    expect(WebMock).not_to have_requested(:post, provider_url)
  end

  it "rejects oversized requests" do
    limit = LeadScoringComponent::Helpers::TranscriptHelper::MAX_BYTES
    expect(post_score(" " * (limit + 1)).status).to eq(413)
  end

  it "rejects unsupported content types" do
    expect(post_score("{}", content_type: "text/plain").status).to eq(415)
  end

  it "returns the allowed method for GET requests to the scoring endpoint" do
    response = app.get("/api/score")
    expect(response.status).to eq(405)
    expect(response["allow"]).to eq("POST")
  end

  it "returns JSON for missing routes" do
    response = app.get("/missing")
    expect(response.status).to eq(404)
    expect(JSON.parse(response.body).dig("error", "code")).to eq("not_found")
  end

  it "reports missing configuration with no fabricated score" do
    ENV.delete("OPENAI_API_KEY")
    response = post_score(payload.to_json)
    expect(response.status).to eq(503)
    expect(JSON.parse(response.body)).to eq("error" => {
      "code" => "configuration_missing", "message" => "OpenAI API key is not configured."
    })
  end

  it "returns provider timeouts as JSON without scores" do
    stub_request(:post, provider_url).to_timeout
    response = post_score(payload.to_json)
    expect(response.status).to eq(504)
    expect(JSON.parse(response.body)).not_to have_key("score")
  end
end
