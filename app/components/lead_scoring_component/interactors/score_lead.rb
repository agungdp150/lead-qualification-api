# frozen_string_literal: true

module LeadScoringComponent
  module Interactors
    # One business action; transport and provider details stay outside this workflow.
    class ScoreLead
      def self.call(raw_body:)
        transcript = Helpers::TranscriptHelper.parse(raw_body)
        evidence = Services::EvidenceExtractorService.new.call(transcript.fetch("conversation"))
        Services::ScoringPolicyService.call(transcript.fetch("lead_id"), evidence)
      end
    end
  end
end
