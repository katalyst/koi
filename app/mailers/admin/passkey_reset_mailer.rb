# frozen_string_literal: true

module Admin
  class PasskeyResetMailer < Koi::ApplicationMailer
    def passkey_reset(user:, token:)
      @user = user
      @token = token

      mail(to: @user.email, subject: "Reset your passkey")
    end
  end
end
