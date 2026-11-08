# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found
    if request.path == "/api/score"
      response.set_header("Allow", "POST")
      render json: { error: { code: "method_not_allowed", message: "Use POST /api/score." } }, status: 405
    else
      render json: { error: { code: "not_found", message: "Endpoint not found." } }, status: 404
    end
  end
end
