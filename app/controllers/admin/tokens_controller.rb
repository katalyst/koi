# frozen_string_literal: true

module Admin
  class TokensController < ApplicationController
    DEVICE_CODE_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:device-code"
    JWT_BEARER_GRANT_TYPE  = "urn:ietf:params:oauth:grant-type:jwt-bearer"

    rate_limit to: 20, within: 1.minute, only: :create
    skip_before_action :verify_authenticity_token, only: :create

    def create
      case params[:grant_type]
      when DEVICE_CODE_GRANT_TYPE
        authorize_device_code
      when JWT_BEARER_GRANT_TYPE
        authorize_bearer_token
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

    def authorize_bearer_token
      assertion = Koi::Identity.authorize_bearer_token!(params[:assertion], audience: "#{request.base_url}/admin")

      admin_user = Admin::User.find_by(assertion.principal.attributes_for_find)

      return render(json: { error: "invalid_grant" }, status: :bad_request) if admin_user.nil?

      device_authorization, device_code = Admin::DeviceAuthorization.issue!(
        requested_ip: request.remote_ip,
        user_agent:   request.user_agent,
      )
      device_authorization.approve!(admin_user:)

      render json: Admin::DeviceAuthorization.issue_access_token!(device_code:)
    rescue JWT::DecodeError
      render json: { error: "invalid_grant" }, status: :bad_request
    end
  end
end
