# frozen_string_literal: true

module Koi
  module Controller
    module JsonWebToken
      extend ActiveSupport::Concern

      SECRET_KEY = Rails.application.secret_key_base

      def encode_token(**payload)
        JWT.encode(payload, SECRET_KEY)
      end

      def decode_token(token)
        payload = JWT.decode(token, SECRET_KEY)[0]
        HashWithIndifferentAccess.new(payload)
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
