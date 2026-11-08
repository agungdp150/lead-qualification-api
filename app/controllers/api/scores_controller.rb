# frozen_string_literal: true

module Api
  class ScoresController < ApplicationController
    def create
      unless request.media_type == "application/json"
        raise ScoringError.new("unsupported_media_type", "Use Content-Type: application/json.", 415)
      end

      raw_body = request.body.read(LeadScoringComponent::Helpers::TranscriptHelper::MAX_BYTES + 1)
      render json: LeadScoringComponent::Interactors::ScoreLead.call(raw_body: raw_body)
    end
  end
end
