# frozen_string_literal: true

module Admin
  class DeviceTokensController < ApplicationController
    def create
      render json: { error: "invalid_request" }, status: :bad_request
    end
  end
end
