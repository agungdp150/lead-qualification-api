# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Health endpoint" do
  it "works without provider credentials" do
    ENV.delete("OPENAI_API_KEY")
    response = Rack::MockRequest.new(Rails.application).get("/health")
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq("status" => "ok")
  end
end
