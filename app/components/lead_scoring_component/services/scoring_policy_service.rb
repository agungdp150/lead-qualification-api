# frozen_string_literal: true

module LeadScoringComponent
  module Services
    class ScoringPolicyService
      WEIGHTS = {
        "import_readiness" => { "licensed" => 25, "experienced" => 18, "pending" => 10, "none" => 0, "unknown" => 0 },
        "product_fit" => { "match" => 25, "mismatch" => 0, "unknown" => 0 },
        "volume" => { "container_monthly" => 30, "below_container" => 10, "personal" => 0, "unknown" => 0 },
        "business" => { "established" => 20, "new" => 8, "unknown" => 0 }
      }.freeze
      ROUTING = { "Hot" => "kam_handoff", "Warm" => "nurture_pool", "Cold" => "auto_archive" }.freeze
      LABELS = {
        "import_readiness" => { "licensed" => "confirmed import license", "experienced" => "importing experience; license unconfirmed", "pending" => "import license pending", "none" => "currently unable to import", "unknown" => "import readiness unknown" },
        "product_fit" => { "match" => "beverage product fit", "mismatch" => "products outside the beverage offering", "unknown" => "product fit unknown" },
        "volume" => { "container_monthly" => "at least one container per month", "below_container" => "smaller or one-off commercial volume", "personal" => "personal-use quantities", "unknown" => "volume unknown" },
        "business" => { "established" => "established business signals", "new" => "new business", "unknown" => "business history unknown" }
      }.freeze

      def self.call(lead_id, evidence)
        score = WEIGHTS.sum { |key, weights| weights.fetch(evidence.fetch(key)) }
        disqualified = evidence["intent"] == "personal" || evidence["volume"] == "personal" || evidence["product_fit"] == "mismatch"
        if disqualified
          score = [score, 39].min
        else
          # Missing information earns follow-up, not irreversible auto-archival.
          score = [score, 40].max
          ready = %w[licensed experienced].include?(evidence["import_readiness"]) &&
            evidence["product_fit"] == "match" && evidence["volume"] == "container_monthly" && evidence["intent"] == "wholesale"
          score = [score, 74].min unless ready
        end
        tier = score >= 75 ? "Hot" : (score >= 40 ? "Warm" : "Cold")
        facts = LABELS.map { |key, labels| labels.fetch(evidence.fetch(key)) }.join("; ")
        action = case tier
                 when "Hot" then "Prioritize KAM follow-up and verify the stated commercial details"
                 when "Warm" then "Nurture and confirm outstanding qualification details"
                 else "Archive because the stated need is outside wholesale beverage qualification"
                 end
        { lead_id: lead_id, score: score, tier: tier, routing: ROUTING.fetch(tier), reasoning: "#{facts.capitalize}. #{action}." }
      end
    end
  end
end
