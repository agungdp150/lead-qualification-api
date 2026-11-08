# frozen_string_literal: true

class ApplicationController < ActionController::API
  wrap_parameters false
  rescue_from ScoringError, with: :render_scoring_error

  private

  def render_scoring_error(error)
    Rails.logger.warn({ event: "scoring_failure", request_id: request.request_id, code: error.code }.to_json)
    render json: { error: { code: error.code, message: error.message } }, status: error.status
  end
end
