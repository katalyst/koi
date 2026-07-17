# frozen_string_literal: true

module Admin
  class TokensController < ApplicationController
    DEVICE_CODE_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:device-code"

    rate_limit to: 20, within: 1.minute, only: :create
    skip_before_action :verify_authenticity_token, only: :create

    def create
      case params[:grant_type]
      when DEVICE_CODE_GRANT_TYPE
        authorize_device_code
      else
        render(json: { error: "invalid_request" }, status: :bad_request)
      end
    end

    private

    def authorize_device_code
      render json: Admin::DeviceAuthorization.issue_access_token!(device_code: params[:device_code])
    rescue Admin::DeviceAuthorization::TokenError => e
      render json: { error: e.code }, status: :bad_request
    end
  end
end
