# frozen_string_literal: true

require "rails_helper"
require_relative "../../lib/vercel_adapter"

RSpec.describe VercelAdapter do
  let(:response) do
    Class.new do
      attr_accessor :status, :body
      def []=(name, value)
        (@headers ||= {})[name] = value
      end
    end.new
  end

  def platform_request(path, method: "GET", body: nil)
    Struct.new(:path, :body, :meta_vars).new(path, body, {
      "REQUEST_METHOD" => method, "SERVER_NAME" => "example.vercel.app", "SERVER_PORT" => "443",
      "QUERY_STRING" => "", "CONTENT_TYPE" => "application/json", "CONTENT_LENGTH" => body.to_s.bytesize.to_s
    })
  end

  it "serves health requests through the platform adapter" do
    described_class.call(Rails.application, platform_request("/health"), response)
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)).to eq("status" => "ok")
  end

  it "preserves scoring request bodies and content types" do
    stub_provider
    request = platform_request("/api/score", method: "POST", body: payload.to_json)
    described_class.call(Rails.application, request, response)
    expect(response.status).to eq(200)
    expect(JSON.parse(response.body)["score"]).to eq(93)
  end
end
