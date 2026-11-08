require "json"
require "net/http"

base = ARGV.fetch(0) { abort "Usage: bundle exec ruby scripts/verify_live.rb https://YOUR-PROJECT.vercel.app" }
uri = URI(base)
abort "Use an HTTP(S) URL" unless %w[http https].include?(uri.scheme) && uri.host
expected = { "hot" => ["Hot", "kam_handoff"], "cold" => ["Cold", "auto_archive"], "ambiguous" => ["Warm", "nurture_pool"] }

expected.each do |name, decision|
  payload = JSON.parse(File.read(File.expand_path("../spec/fixtures/lead_scoring/#{name}.json", __dir__)))
  endpoint = URI.join(base.end_with?("/") ? base : "#{base}/", "api/score")
  request = Net::HTTP::Post.new(endpoint)
  request["Content-Type"] = "application/json"
  request.body = JSON.generate(payload)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  response = Net::HTTP.start(endpoint.host, endpoint.port, use_ssl: endpoint.scheme == "https", open_timeout: 5, read_timeout: 30) { |http| http.request(request) }
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  abort "#{name}: HTTP #{response.code}: #{response.body}" unless response.code == "200"
  data = JSON.parse(response.body)
  valid = data.keys.sort == %w[lead_id reasoning routing score tier] && data["lead_id"] == payload["lead_id"] &&
    data["score"].is_a?(Integer) && (0..100).cover?(data["score"]) &&
    data.values_at("tier", "routing") == decision && data["reasoning"].is_a?(String) && !data["reasoning"].strip.empty?
  score_tier = data["score"].is_a?(Integer) ? (data["score"] >= 75 ? "Hot" : (data["score"] >= 40 ? "Warm" : "Cold")) : nil
  abort "#{name}: invalid contract/decision: #{data}" unless valid && score_tier == data["tier"]
  abort "#{name}: exceeded 30 seconds (#{elapsed.round(2)}s)" unless elapsed < 30
  puts JSON.generate(sample: name, seconds: elapsed.round(3), result: data)
end
puts "All supplied examples passed live contract, routing, and latency checks; manually review the rationales."
