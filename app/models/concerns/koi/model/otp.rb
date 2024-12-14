# frozen_string_literal: true

module Koi
  module Model
    module OTP
      extend ActiveSupport::Concern

      included do
        attribute :token, :string
      end

      def requires_otp?
        otp_secret.present?
      end

      def otp
        ROTP::TOTP.new(otp_secret) if otp_secret.present?
      end
    end
  end
end
