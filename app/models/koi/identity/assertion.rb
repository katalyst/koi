# frozen_string_literal: true

module Koi
  module Identity
    class Assertion
      # @return String
      attr_reader :token

      # @return Principal
      attr_reader :principal

      def initialize(token)
        @token           = token
        @claims, @header = JWT.decode(token, nil, false)
        @state           = :unverified
      end

      def verified?
        @state == :verified
      end

      def claims
        @claims
      end

      def header
        @header
      end

      def verify!(provider)
        JWT.decode(
          @token, nil, true,
          algorithms: provider.algorithms,
          jwks:       provider.method(:key_set),
          aud:        provider.audience,
          sub:        provider.subject,
          leeway:     provider.leeway.to_i,
          verify_aud: true,
          verify_jti: provider.method(:consume_jti),
          verify_sub: true
        )

        @state     = :verified
        @principal = provider.principal_for(self)

        self
      end

      def iss
        @claims["iss"]
      end
      alias_method :issuer, :iss

      def sub
        @claims["sub"]
      end
      alias_method :subject, :sub

      def inspect
        "<#{self.class.name} iss=#{iss.inspect} sub=#{sub.inspect}>"
      end
    end
  end
end
