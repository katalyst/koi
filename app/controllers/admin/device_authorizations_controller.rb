# frozen_string_literal: true

module Admin
  class DeviceAuthorizationsController < ApplicationController
    EXPIRES_IN = 10.minutes
    INTERVAL = 5

    rate_limit to: 3, within: 1.minute, only: :create
    skip_before_action :verify_authenticity_token, only: :create

    before_action :set_device_authorization, only: %i[show update]

    attr_reader :device_authorization

    delegate :admin_user, to: ::Koi::Current

    def show
      render locals: { device_authorization: }
    end

    def create
      device_authorization, device_code = Admin::DeviceAuthorization.issue!(
        requested_ip: request.remote_ip,
        user_agent:   request.user_agent,
      )

      render json: {
        device_code:,
        user_code:                 device_authorization.user_code,
        verification_uri:          admin_device_authorization_url(device_authorization.user_code),
        verification_uri_complete: admin_device_authorization_url(device_authorization.user_code),
        expires_in:                EXPIRES_IN.to_i,
        interval:                  INTERVAL,
      }
    end

    def update
      if device_authorization.actionable?
        case params[:decision]
        when "approve"
          device_authorization.approve!(admin_user:)
        else
          device_authorization.deny!(admin_user:)
        end

        redirect_to(admin_device_authorization_path(device_authorization.user_code), status: :see_other)
      else
        render(:show, status: :unprocessable_content, locals: { device_authorization: })
      end
    end

    private

    def set_device_authorization
      @device_authorization = Admin::DeviceAuthorization.find_by!(user_code: params[:user_code])
    end
  end
end
