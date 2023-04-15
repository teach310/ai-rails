# frozen_string_literal: true

class ApiController < ActionController::API
  private

  def respond_success(data)
    render status: :ok, json: { data: }
  end
end
