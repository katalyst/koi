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
        # The library validates required_claims after verify_jti, but
        # consume_jti derives its cache TTL from exp — so require it first.
        raise JWT::MissingRequiredClaim, "missing required claim exp" if claims["exp"].nil?

        JWT.decode(
          @token, nil, true,
          algorithms:      provider.algorithms,
          jwks:            provider.method(:key_set),
          aud:             provider.audience,
          leeway:          provider.leeway.to_i,
          required_claims: %w[exp],
          verify_aud:      true,
          verify_jti:      provider.method(:consume_jti)
        )

        if claims["exp"].to_i > provider.max_expiry.from_now.to_i
          raise JWT::InvalidPayload, "assertion expiry is more than #{provider.max_expiry.inspect} away"
        end

        # ensure that we can map the claim to a valid principal using the claim's subject
        @principal = Identity.principal_for(provider, self)

        if principal.blank? || principal.subject.blank?
          raise(JWT::InvalidSubError, "unknown subject #{subject} for provider #{provider.name}")
        end

        @state = :verified

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
      alias :to_s :inspect
    end
  end
end
