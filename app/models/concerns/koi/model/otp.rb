# frozen_string_literal: true

module Koi
  module Model
    module OTP
      extend ActiveSupport::Concern

      def requires_otp?
        otp_secret.present?
      end

      def otp
        ROTP::TOTP.new(otp_secret) if otp_secret.present?
      end
    end
  end
end
