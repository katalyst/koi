# frozen_string_literal: true

module Koi
  class Current < ActiveSupport::CurrentAttributes
    # @return [Admin::Session,nil]
    attribute :admin_session

    # @return [Admin::User,nil]
    attribute :admin_user

    def admin_user
      super || admin_session&.admin
    end
  end
end
