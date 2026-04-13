# frozen_string_literal: true

module Admin
  class DeviceAuthorizationsController < ApplicationController
    EXPIRES_IN = 10.minutes
    INTERVAL = 5

    rate_limit to: 3, within: 1.minute

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
  end
end
