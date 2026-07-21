# frozen_string_literal: true

module Koi
  class Current < ActiveSupport::CurrentAttributes
    # @return [Admin::DeviceAuthorization, nil]
    attribute :device_authorization

    # @return [Admin::Session, nil]
    attribute :session

    # @return [Admin::User, Admin::Role, nil]
    def actor
      device_authorization&.actor || session&.admin
    end

    # @return [Koi::Identity::Principal, nil]
    def principal
      device_authorization&.principal
    end

    # @return [Admin::User, nil]
    def admin_user
      device_authorization&.admin_user || session&.admin
    end
  end
end
