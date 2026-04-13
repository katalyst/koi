# frozen_string_literal: true

module Admin
  class DeviceTokensController < ApplicationController
    GRANT_TYPE = "urn:ietf:params:oauth:grant-type:device_code"

    rate_limit to: 20, within: 1.minute, only: :create
    skip_before_action :verify_authenticity_token, only: :create

    def create
      return render(json: { error: "invalid_request" }, status: :bad_request) unless params[:grant_type] == GRANT_TYPE

      render json: Admin::DeviceAuthorization.issue_access_token!(device_code: params[:device_code])
    rescue Admin::DeviceAuthorization::TokenError => e
      render json: { error: e.code }, status: :bad_request
    end
  end
end
