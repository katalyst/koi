# frozen_string_literal: true

module Koi
  class Current < ActiveSupport::CurrentAttributes
    # @return [Admin::DeviceAuthorization, nil]
    attribute :device_authorization

    # @return [Admin::Session, nil]
    attribute :session

    # @return [Admin::User, nil]
    def admin_user
      device_authorization&.admin_user || session&.admin
    end
  end
end
